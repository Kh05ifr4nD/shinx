{
  lib,
  flake,
  pkgs,
  ...
}:
let
  inherit (flake.config) user;
in
{
  home = {
    homeDirectory = lib.mkDefault "/${
      if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home"
    }/${user.name}";
    stateVersion = lib.mkDefault "26.05";
    preferXdgDirectories = true;
    username = user.name;
  };

  imports = with builtins; map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)));
  nix = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    extraOptions = ''
      !include /run/secrets/rendered/nix/access-tokens.conf
    '';
  };
  xdg.enable = true;
}
