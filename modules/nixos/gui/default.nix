{ pkgs, ... }:
{
  programs = {
    dconf = {
      enable = true;
    };

    localsend = {
      enable = true;
      openFirewall = false;
    };
  };
  services = {
    v2raya.enable = true;
  };
}
