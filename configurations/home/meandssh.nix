{ flake
, pkgs
, lib
, ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];
  home = {
    homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/meandssh";
    stateVersion = "24.05";
    username = "meandssh";
  };
}
