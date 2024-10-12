{ inputs, ... }:
{
  imports = [
    inputs.flake-root.flakeModule
    inputs.treefmt-nix.flakeModule
  ];
  perSystem =
    { config, ... }:
    {
      treefmt.config = {
        inherit (config.flake-root) projectRootFile;
        programs = {
          nixfmt.enable = true;
          taplo.enable = true;
        };
      };
    };
}
