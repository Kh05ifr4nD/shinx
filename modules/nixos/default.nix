# This is your nix-darwin configuration.
# For home configuration, see /modules/home/*
{
  flake,
  pkgs,
  lib,
  ...
}:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  environment = {
    systemPackages = with pkgs; [
      # Flakes clones its dependencies through the git command,
      # so git must be installed first
      bat
      curl
      git
      helix
      nushell
      ripgrep
      kdePackages.breeze
      unzip
      wget
      xz
      yazi
    ];
    variables.EDITOR = "hx";
  };
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)))
    ++ (with inputs; [
      nix-ld.nixosModules.nix-ld
      sops-nix.nixosModules.sops
    ]);
  programs.nix-ld.dev.enable = true;
  services.openssh.enable = true;
}
