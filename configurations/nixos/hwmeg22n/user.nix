{
  flake,
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
    users."${usr}" = {
      imports = [ (self + /configurations/home/${usr}.nix) ];
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
  system.stateVersion = "24.05";
  users.users.meandssh = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    shell = pkgs.nushell;
  };
  wsl.defaultUser = usr;
}
