{
  flake,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.base
  ];
  _module.args = {
    usr = baseNameOf ./.;
  };
}
