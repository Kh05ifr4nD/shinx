{ pkgs, ... }:
{
  programs = {
    dconf = {
      enable = true;
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
