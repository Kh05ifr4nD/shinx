{
  pkgs,
  ...
}:
{
  imports = [
    ./clipboard.nix
    ./qt.nix
  ];
  xsession.numlock.enable = true;
}
