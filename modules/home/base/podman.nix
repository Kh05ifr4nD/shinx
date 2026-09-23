{ lib, pkgs, ... }:

{
  home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
    with pkgs;
    [
      podman
      podman-compose
    ]
  );
}
