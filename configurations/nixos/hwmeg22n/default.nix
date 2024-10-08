{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports =
    with builtins;
    map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)))
    ++ [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.default
    ];
  _module.args = {
    hst = baseNameOf (toString ./.);
    usr = "meandssh";
  };
}
