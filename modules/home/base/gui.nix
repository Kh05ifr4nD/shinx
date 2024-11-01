{ pkgs, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
  };
  home.packages = with pkgs; [
    code-cursor
    firefox-esr
    qq
    (warp-terminal.override { waylandSupport = true; })
    xclip
    xsel
    wl-clipboard
    zed-editor
    zotero
  ];
  qt = {
    enable = true;
  };
}
