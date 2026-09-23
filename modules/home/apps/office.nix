{ lib, pkgs, ... }:
{
  home.packages = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) [ pkgs.libreoffice-qt6-still ];
}
