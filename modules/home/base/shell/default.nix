{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  proxyEnv = import (flake.inputs.self + /modules/proxy-env.nix) { inherit lib; };
  darwinPath = [
    "${config.home.homeDirectory}/.nix-profile/bin"
    "${config.home.profileDirectory}/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
in
{
  home.sessionVariables = proxyEnv;

  programs = {
    atuin = {
      enable = true;
      enableNushellIntegration = true;
    };
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    nushell = {
      configDir = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "Library/Application Support/nushell";
      configFile.source = ./nushell/config.nu;
      enable = true;
      envFile.source = ./nushell/env.nu;
      environmentVariables = proxyEnv;
      extraEnv = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        $env.PATH = ${lib.hm.nushell.toNushell { } darwinPath}
      '';
      loginFile.source = ./nushell/login.nu;
      shellAliases = {
        cd = "z";
        j = "just";
      };
    };
    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = fromTOML (builtins.readFile ./starship.toml);
    };
    zellij = {
      enable = true;
    };
  };
}
