{ inputs, ... }:
{
  imports =
    with inputs.nixos-unified.flakeModules;
    [
      autoWire
      default
    ]
    ++ (with inputs; [
      flake-root.flakeModule
      git-hooks-nix.flakeModule
      treefmt-nix.flakeModule
    ]);
  perSystem =
    { self', ... }:
    {
      packages.default = self'.packages.activate;
    };
}
