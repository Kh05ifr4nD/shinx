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
      inputs.helix.packages."${pkgs.system}".helix
      nushell
      ripgrep
      wget
      xz
      yazi
    ];
    variables.EDITOR = "hx";
  };
  imports =
    with builtins;
    map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));
  programs.nix-ld.dev.enable = true;
  services.openssh.enable = true;
}
