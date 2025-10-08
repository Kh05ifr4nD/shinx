{
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake.config) user;
  hasAuthorizedKey = user.pub-key != "";
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
    shell = pkgs.nushell;
  }
  // lib.optionalAttrs hasAuthorizedKey {
    openssh.authorizedKeys.keys = [ user.pub-key ];
  };
}
