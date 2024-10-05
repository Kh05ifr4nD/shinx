{ pkgs, ... }:
{
  home.packages = with pkgs; [
    file
    hyperfine
  ];
  programs = {
    bat = {
      enable = true;
    };
    btop = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fastfetch = {
      enable = true;
    };
    fd = {
      enable = true;
    };
    fzf = {
      enable = true;
    };
    ripgrep = {
      enable = true;
    };
    yazi = with builtins; {
      enable = true;
      enableNushellIntegration = true;
      settings = fromTOML (readFile ./yazi/yazi.toml);
      theme = fromTOML (readFile ./yazi/catppuccin-mocha.toml);
    };
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
