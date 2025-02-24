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
    (warp-terminal.override { waylandSupport = true; })
    xclip
    xsel
    wl-clipboard
    xournalpp
    zed-editor
    zotero
  ];
  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "zh-CN" ];
      nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
    };
  };
  qt = {
    enable = true;
  };
}
