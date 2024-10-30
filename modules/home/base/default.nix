{
  lib,
  pkgs,
  usr,
  ...
}:
{
  home = {
    homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${usr}";
    preferXdgDirectories = true;
    stateVersion = "24.05";
    username = usr;
  };

  imports = with builtins; map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)));
  xdg.enable = true;
}
