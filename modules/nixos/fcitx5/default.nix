{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-gtk
        fcitx5-pinyin-minecraft
        fcitx5-pinyin-moegirl
        fcitx5-pinyin-zhwiki
        kdePackages.fcitx5-qt
      ];
      plasma6Support = true;
    };
    type = "fcitx5";
  };
}
