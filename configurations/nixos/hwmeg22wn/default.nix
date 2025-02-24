{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = with self.nixosModules; [
    base
    gui
    wsl
  ];
  _module.args = {
    arch = "aarch64-linux";
    host = baseNameOf ./.;
  };
}
