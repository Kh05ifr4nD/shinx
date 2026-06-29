{ lib, pkgs, ... }:
{
  home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [ pkgs.zotero ];
}
