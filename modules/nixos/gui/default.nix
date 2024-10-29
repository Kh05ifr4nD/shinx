{ pkgs, ... }:
{
  programs = {
    dconf = {
      enable = true;
    };
  };
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
