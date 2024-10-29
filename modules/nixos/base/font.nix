{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaMono" ]; })
      noto-fonts-color-emoji
      source-sans-pro
      source-serif-pro
      source-han-sans
      source-han-serif
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "Source Han Serif"
          "Source Serif Pro"
        ];
        sansSerif = [
          "Source Han Sans"
          "Source Snas Pro"
        ];
        monospace = [ "CascadiaMono" ];
      };
    };
  };
}
