{
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake.config) user;

in
{
  home-manager = {
    useGlobalPkgs = true;
    users.${user.name} = {
      imports = [ (flake.inputs.self + /configurations/home/base) ];
    };
    useUserPackages = true;
  };
  nix.settings = {
    allowed-users = [ user.name ];
    trusted-users = [
      user.name
      "root"
    ];
  };
  users.users.${user.name} = {
    extraGroups = lib.mkBefore [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ user.pub-key ];
    shell = pkgs.nushell;
  };
}
