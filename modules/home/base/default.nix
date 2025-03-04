{ flake
, lib
, pkgs
, ...
}:
let
  inherit (flake.config) user;
in
{
  home = {
    homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${user.name}";
    preferXdgDirectories = true;
    stateVersion = "24.05";
    username = user.name;
  };

  imports = with builtins; map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)));
  xdg = {
    enable = true;
    portal = {
      config = {
        common = {
          default = "*";
        };
      };
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      xdgOpenUsePortal = true;
    };
  };
  xsession.numlock.enable = true;
}
