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
      hardware
      network
      sshd
    ]);

  _module.args = {
    arch = "x86_64-linux";
    host = baseNameOf ./.;
  };
}
