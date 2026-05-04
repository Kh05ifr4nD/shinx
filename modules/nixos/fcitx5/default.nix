{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    fcitx5 = {
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-gtk
        fcitx5-pinyin-minecraft
        fcitx5-pinyin-moegirl
        fcitx5-pinyin-zhwiki
        qt6Packages.fcitx5-configtool
        kdePackages.fcitx5-qt
        kdePackages.fcitx5-chinese-addons
      ];
      waylandFrontend = true;
    };
    type = "fcitx5";
  };
}
