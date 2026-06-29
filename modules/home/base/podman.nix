{ lib, pkgs, ... }:

{
  home.packages = lib.mkIf pkgs.stdenv.isLinux (
    with pkgs;
    [
      podman
      podman-compose
    ]
  );
}
