{
  flake,
  lib,
  ...
}:

let
  inherit (flake.config) user;
in
{
  networking = {
    firewall = {
      enable = true;
    };
    networkmanager.enable = true;
  };
  users.users.${user.name}.extraGroups = lib.mkAfter [ "networkmanager" ];
}
