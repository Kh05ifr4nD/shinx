{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)))
    ++ (with self.nixosModules; [
      base
      fcitx5
      gui
      network
      nvidia
    ])
    ++ (with self.homeModules; [
      kde
    ]);
  _module.args = {
    arch = "x86_64-linux";
    hst = baseNameOf ./.;
    pk = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/tD28+bZ/dJiBqBSxpZ96A4GBniGy2eLTkvlj9/ElQ";
    usr = "meandssh";
  };
}
