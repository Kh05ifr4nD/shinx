{
  flake,
  pk,
  pkgs,
  usr,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  home-manager = {
    useGlobalPkgs = true;
    users.${usr} = {
      imports = [ (self + /configurations/home/${usr}) ];
    };
    useUserPackages = true;
  };
  nix.settings = {
    allowed-users = [ usr ];
    trusted-users = [
      usr
      "root"
    ];
  };
  users.users.${usr} = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ pk ];
    shell = pkgs.nushell;
  };
}
