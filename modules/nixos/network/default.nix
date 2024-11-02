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
  networking = {
    firewall = {
      enable = true;
    };
    networkmanager.enable = true;
  };
  users.users.${usr}.extraGroups = lib.mkAfter [ "networkmanager" ];
}
