{ flake, pkgs, ... }:
let
  inherit (flake.config) user;
in
{
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-kde
  ];
  home-manager.users.${user.name} = {
    imports = [ (flake.inputs.self + /configurations/home/gui) ];
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
  services = {
    v2raya.enable = true;
  };
}
