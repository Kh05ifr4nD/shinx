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
  home = {
    homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${user.name}";
    preferXdgDirectories = true;
    username = user.name;
  };

  imports = with builtins; map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)));
  xdg.enable = true;
}
