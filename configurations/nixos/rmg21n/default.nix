{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)))
    ++ [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.default
    ];
  _module.args = {
    hst = baseNameOf ./.;
    usr = "meandssh";
  };
}