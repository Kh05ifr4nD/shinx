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
      audio
      base
      bluetooth
      fcitx5
      gui
      hardware
      kde
      network
      nvidia
    ]);
  _module.args = {
    arch = "x86_64-linux";
    host = baseNameOf ./.;
  };
}
