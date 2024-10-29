{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
    file
    hyperfine
  ];
  programs = {
    btop = {
      enable = true;
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
