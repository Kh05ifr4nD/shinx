{ pkgs, ... }:
{
  home.packages = with pkgs; [
    just
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
