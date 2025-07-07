{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
  ];
  programs = {
    direnv = {
      config.global = {
        hide_env_diff = true;
      };
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
