{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = with self.nixosModules; [
    base
    wsl
  ];
  _module.args = {
    arch = "x86_64-linux";
    host = baseNameOf ./.;
  };
  system.stateVersion = "25.05";
  modules.home.stateVersion = "25.05";
}
