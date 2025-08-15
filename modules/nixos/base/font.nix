{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      lxgw-wenkai
      nerd-fonts.caskaydia-cove
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-extra
      source-sans-pro
      source-serif-pro
      source-han-sans
      source-han-serif
    ];

    fontconfig = {
      defaultFonts = {
        emoji = [
          "Noto Color Emoji"
        ];
        serif = [
          "Source Han Serif"
          "Source Serif Pro"
        ];
        sansSerif = [
          "Source Han Sans"
          "Source Sans Pro"
        ];
        monospace = [ "CascadiaMono" ];
      };
      enable = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
      };
    };
  };
}
