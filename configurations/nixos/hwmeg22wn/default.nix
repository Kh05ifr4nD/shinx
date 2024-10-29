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
    hst = baseNameOf ./.;
    pk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/tD28+bZ/dJiBqBSxpZ96A4GBniGy2eLTkvlj9/ElQ";
    usr = "meandssh";
  };
}
