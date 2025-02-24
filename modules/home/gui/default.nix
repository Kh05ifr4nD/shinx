{
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    libreoffice-qt6-still
    microsoft-edge
    obs-studio
    qq
    vlc
    wechat-uos
  ];
}
