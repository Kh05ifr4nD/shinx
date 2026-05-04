{ flake, ... }:
let
  inherit (flake.inputs) self;
in
{
  imports = with self.darwinModules; [
    base
    clt
    font
    guiForSingBox
    homebrew
    sops
  ];

  modules.host = {
    arch = "aarch64-darwin";
    name = "aa3448";
  };
  modules.clt = {
    autoInstall = true;
    enable = true;
  };
}
