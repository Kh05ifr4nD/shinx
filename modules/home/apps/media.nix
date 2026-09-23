{ lib, pkgs, ... }:
{
  home.packages = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) [ pkgs.vlc ];
}
