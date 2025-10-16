{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
  ];
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
