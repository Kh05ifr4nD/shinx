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
  modules.host = {
    arch = "x86_64-linux";
    name = baseNameOf ./.;
  };
  system.stateVersion = "25.05";
  modules.home.stateVersion = "25.05";
}
