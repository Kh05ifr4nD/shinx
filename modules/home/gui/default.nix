{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    libreoffice-qt6-still
    microsoft-edge
    obs-studio
    vlc
    zotero
  ];
  # programs = {
  #   firefox = {
  #     enable = true;
  #     languagePacks = [ "zh-CN" ];
  #     nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
  #   };
  # };
}
