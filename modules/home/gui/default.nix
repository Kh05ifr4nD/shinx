{
  pkgs,
  ...
}:
{
  # Include small GUI helpers (clipboard/qt) and keep existing GUI apps here
  imports = [
    ./clipboard.nix
    ./qt.nix
  ];

  home.packages = with pkgs; [
    libreoffice-qt6-still
    microsoft-edge
    obs-studio
    vlc
    zotero
  ];

  # GUI-specific user session behavior
  xsession.numlock.enable = true;

  # programs.firefox can be enabled via a dedicated apps bundle if needed
}
