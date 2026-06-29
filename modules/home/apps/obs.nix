{ lib, pkgs, ... }:
{
  home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [ pkgs.obs-studio ];
}
