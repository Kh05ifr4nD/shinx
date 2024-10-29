{ inputs, ... }:
{
  imports = with inputs.nixos-unified.flakeModules; [
    autoWire
    default
  ];
  perSystem =
    { self', pkgs, ... }:
    {
      packages.default = self'.packages.activate;
    };
}
