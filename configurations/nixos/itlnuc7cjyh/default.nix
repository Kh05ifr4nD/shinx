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
      kmscon
      network
      sshd
      sgx
    ]);

  modules.host = {
    arch = "x86_64-linux";
    name = baseNameOf ./.;
  };
  system.stateVersion = "25.05";
  modules.home.stateVersion = "25.05";
}
