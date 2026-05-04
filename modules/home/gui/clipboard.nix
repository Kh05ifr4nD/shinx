{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    xclip
    xsel
  ];
  qt = {
    enable = true;
  };
}
