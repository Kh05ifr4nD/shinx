{ inputs, ... }:
{
  imports =
    with inputs.nixos-unified.flakeModules;
    [
      autoWire
      default
    ]
    ++ [ inputs.flake-root.flakeModule ];
  perSystem =
    { self', ... }:
    {
      packages.default = self'.packages.activate;
    };
}
