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
  modules.home.imports = with self.homeModules; [
    gui
    apps
  ];
  modules.host = {
    arch = "x86_64-linux";
    name = baseNameOf ./.;
  };
  system.stateVersion = "25.05";
  modules.home.stateVersion = "25.05";
}
