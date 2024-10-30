{
  flake,
  lib,
  pkgs,
  usr,
  ...
}:

let
  inherit (flake) inputs;
in
{
  networking.networkmanager.enable = true;
  users.users.${usr}.extraGroups = lib.mkAfter [ "networkmanager" ];
}
