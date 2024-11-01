{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-chinese-addons
        fcitx5-gtk
        fcitx5-pinyin-minecraft
        fcitx5-pinyin-moegirl
        fcitx5-pinyin-zhwiki
      ];
      plasma6Support = true;
    };
  };
}
