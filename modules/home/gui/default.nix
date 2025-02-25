{
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    (warp-terminal.override { waylandSupport = true; })
    code-cursor
    libreoffice-qt6-still
    microsoft-edge
    obs-studio
    qq
    vlc
    wechat-uos
    wl-clipboard
    xclip
    xournalpp
    xsel
    zotero
  ];
  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "zh-CN" ];
      nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
    };
  };
}
