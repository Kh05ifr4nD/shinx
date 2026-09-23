{ pkgs, ... }:
{
  home.packages = with pkgs; [
    beets
    cue
    nixd
    nixfmt
    yq-go
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
