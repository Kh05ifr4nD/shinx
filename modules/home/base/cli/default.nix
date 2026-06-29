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
      flavors.catppuccin-mocha = ./yazi/catppuccin-mocha.yazi;
      settings = fromTOML (readFile ./yazi/yazi.toml);
      shellWrapperName = "y";
      theme = fromTOML (readFile ./yazi/theme.toml);
    };
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
