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
    preferXdgDirectories = true;
    stateVersion = "24.05";
    username = usr;
  };
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)))
    ++ [
      self.homeModules.default
    ];
  xdg.enable = true;
}
