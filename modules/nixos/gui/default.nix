{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
in
{
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-kde
  ];
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
  services = {
    v2raya.enable = true;
  };
}
