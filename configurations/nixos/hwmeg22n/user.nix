{
  flake,
  pkgs,
  usr,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  pk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/tD28+bZ/dJiBqBSxpZ96A4GBniGy2eLTkvlj9/ElQ";
in
{
  home-manager = {
    useGlobalPkgs = true;
    users."${usr}" = {
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
  users.users.meandssh = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ pk ];
    shell = pkgs.nushell;
  };
  wsl.defaultUser = usr;
}
