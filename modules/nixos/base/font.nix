{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      lxgw-wenkai
      maple-mono.NF-CN-unhinted
      noto-fonts-color-emoji
      source-han-sans
      source-han-serif
      source-sans
      source-serif
    ];

    fontconfig = {
      defaultFonts = {
        emoji = [
          "Noto Color Emoji"
        ];
        monospace = [ "Maple Mono NF CN" ];
        sansSerif = [
          "Source Sans"
          "Source Han Sans"
        ];
        serif = [
          "Source Han Serif SC"
          "Source Serif"
          "Source Han Serif"
          "LXGW WenKai"
        ];
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
