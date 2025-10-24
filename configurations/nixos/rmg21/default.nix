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
      kmscon
      kde
      network
      nvidia
    ]);
  # Home imports for GUI are configured per-host to avoid module→config coupling
  modules.home.imports = [ (self + /configurations/home/gui) ];
  _module.args = {
    arch = "x86_64-linux";
    host = baseNameOf ./.;
  };
}
