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
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
    xdgOpenUsePortal = true;
  };

  programs = {
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
