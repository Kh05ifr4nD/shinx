{
  flake,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)))
    ++ [
      self.homeModules.base
    ];
  _module.args = {
    usr = baseNameOf ./.;
  };
}
