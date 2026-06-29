{ lib, pkgs, ... }:
{
  home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [ pkgs.libreoffice-qt6-still ];
}
