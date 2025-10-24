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

  # GUI-specific user session behavior
  xsession.numlock.enable = true;

  # Apps are now provided via opt-in bundles under modules/home/apps/*
}
