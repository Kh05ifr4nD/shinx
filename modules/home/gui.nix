{ pkgs, ... }:
{
  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
  gtk = {
    enable = true;
    gtk3 = {
      bookmarks = [
        "file:///tmp"
      ];
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };
  dconf.settings."org/gtk/settings/file-chooser" = {
    sort-directories-first = true;
  };

  home.packages = with pkgs; [
    gnome-tweaks
    (warp-terminal.override { waylandSupport = true; })
    zed-editor
  ];
}
