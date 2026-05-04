{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixfmt
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
