{ pkgs, ... }:
{
  home.packages = with pkgs; [
    devenv
    just
    nixd
    nixfmt-rfc-style
    ruff
    uv
  ];
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
