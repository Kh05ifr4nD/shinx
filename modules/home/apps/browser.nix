{ pkgs, ... }:
{
  home.packages = [ pkgs.microsoft-edge ];
  # If you prefer firefox via HM, uncomment below
  # programs.firefox.enable = true;
}
