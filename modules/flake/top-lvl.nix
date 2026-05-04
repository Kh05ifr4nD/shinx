{
  config,
  inputs,
  lib,
  self,
  ...
}:
let
  mapAttrsMaybe =
    f: attrs:
    lib.pipe attrs [
      (lib.mapAttrsToList f)
      (builtins.filter (x: x != null))
      builtins.listToAttrs
    ];

  forAllNixFiles =
    dir: f:
    if builtins.pathExists dir then
      lib.pipe dir [
        builtins.readDir
        (mapAttrsMaybe (
          fn: type:
          if type == "regular" then
            let
              name = lib.removeSuffix ".nix" fn;
            in
            if name != fn then lib.nameValuePair name (f "${dir}/${fn}") else null
          else if type == "directory" && builtins.pathExists "${dir}/${fn}/default.nix" then
            lib.nameValuePair fn (f "${dir}/${fn}")
          else
            null
        ))
      ]
    else
      { };

  specialArgsFor = rec {
    common = {
      flake = {
        inherit config inputs self;
      };
    };
    darwin = common;
    nixos = common;
  };

  homeModuleCommon =
    { config, pkgs, ... }:
    {
      home.homeDirectory = lib.mkDefault "/${
        if pkgs.stdenv.isDarwin then "Users" else "home"
      }/${config.home.username}";
      home.sessionPath = lib.mkIf pkgs.stdenv.isDarwin [
        "/etc/profiles/per-user/$USER/bin"
        "/nix/var/nix/profiles/system/sw/bin"
        "/usr/local/bin"
      ];
    };

  nixosModules = rec {
    common =
      { lib, ... }:
      {
        nix.settings = {
          experimental-features = lib.mkDefault "nix-command flakes";
        };
      };

    home-manager = {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = specialArgsFor.nixos;
            sharedModules = [ homeModuleCommon ];
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }
      ];
    };
  };

  darwinModules = rec {
    common =
      { lib, ... }:
      {
        nix.settings = {
          experimental-features = lib.mkDefault "nix-command flakes";
        };
      };

    home-manager = {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = specialArgsFor.darwin;
            sharedModules = [ homeModuleCommon ];
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }
      ];
    };
  };

  mkLinuxSystem =
    {
      home-manager ? false,
    }:
    mod:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = specialArgsFor.nixos;
      modules = [
        "${inputs.nixos-unified}/nix/modules/configurations"
        nixosModules.common
        mod
      ]
      ++ lib.optional home-manager nixosModules.home-manager;
    };

  mkDarwinSystem =
    {
      home-manager ? false,
    }:
    mod:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = specialArgsFor.darwin;
      modules = [
        "${inputs.nixos-unified}/nix/modules/configurations"
        darwinModules.common
        mod
      ]
      ++ lib.optional home-manager darwinModules.home-manager;
    };

  mkHomeConfiguration =
    pkgs: mod:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = specialArgsFor.common;
      modules = [
        homeModuleCommon
        mod
      ];
    };
in
{
  imports = with inputs; [
    flake-root.flakeModule
    git-hooks-nix.flakeModule
    treefmt-nix.flakeModule
  ];

  flake = {
    darwinConfigurations = forAllNixFiles "${self}/configurations/darwin" (
      fn: mkDarwinSystem { home-manager = true; } fn
    );

    darwinModules = forAllNixFiles "${self}/modules/darwin" (fn: fn);

    lib.shinx = {
      inherit
        mkDarwinSystem
        mkHomeConfiguration
        mkLinuxSystem
        specialArgsFor
        ;
      homeModules = forAllNixFiles "${self}/modules/home" (fn: fn);
    };

    nixosConfigurations = forAllNixFiles "${self}/configurations/nixos" (
      fn: mkLinuxSystem { home-manager = true; } fn
    );

    nixosModules = forAllNixFiles "${self}/modules/nixos" (fn: fn);

    overlays = forAllNixFiles "${self}/overlays" (fn: import fn specialArgsFor.common);
  };

  perSystem =
    {
      inputs',
      pkgs,
      self',
      system,
      ...
    }:
    let
      localPackages = forAllNixFiles "${self}/packages" (fn: pkgs.callPackage fn { });
    in
    {
      legacyPackages.homeConfigurations = forAllNixFiles "${self}/configurations/home" (
        fn: mkHomeConfiguration pkgs fn
      );

      packages =
        (lib.filterAttrs (_: pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg) localPackages)
        // {
          activate = import "${inputs.nixos-unified}/activate" {
            inherit
              inputs'
              lib
              pkgs
              self
              system
              ;
          };
          default = self'.packages.activate;
          update = pkgs.writeShellApplication {
            name = "update-main-flake-inputs";
            meta.description = "Update the primary flake inputs";
            text = ''
              nix flake update nixpkgs home-manager
            '';
          };
        };
    };
}
