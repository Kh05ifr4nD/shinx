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
  # Home imports moved to per-host configurations to avoid module→config coupling

  # Wayland-only portal selection (no GNOME/GTK; wlroots/niri friendly)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
    xdgOpenUsePortal = true;
  };

  programs = {
    # no dconf (GNOME) to avoid GTK/GNOME dependency footprint
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
