{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  usr = baseNameOf ./.;
in
{
  home = {
    homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${usr}";
    stateVersion = "24.05";
    username = usr;
  };
  imports = [
    self.homeModules.default
  ];
}
