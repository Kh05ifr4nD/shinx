{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (flake.config) user;
in
{
  imports = [ ../nix-ld/desktop.nix ];
  # Home imports: route via modules.home.imports for consistency
  modules.home.imports = [ (flake.inputs.self + /configurations/home/gui) ];

  # Prefer the NixOS-side portal configuration to avoid HM duplication
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-kde ];
    config.common.default = "*";
    xdgOpenUsePortal = true;
  };

  programs = {
    dconf = {
      enable = true;
    };
    firefox = {
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
    localsend = {
      enable = true;
      openFirewall = true;
    };
  };
  services.v2raya.enable = true;
}
