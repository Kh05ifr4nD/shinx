{ pkgs, ... }:
{
  home.packages = with pkgs; [
    just
    nixd
  ];
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
