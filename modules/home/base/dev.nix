{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixd
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
