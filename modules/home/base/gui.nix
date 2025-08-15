{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xclip
    xsel
    wl-clipboard
  ];
  qt = {
    enable = true;
  };
}
