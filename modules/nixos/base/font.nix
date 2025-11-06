{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      lxgw-wenkai
      maple-mono.NF-CN
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
        monospace = [ "MapleMono-NF-CN" ];
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
