{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  un = "meandssh";
in
{
  home = {
    homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${un}";
    stateVersion = "24.05";
    username = un;
  };
  imports = [
    self.homeModules.default
  ];
}
