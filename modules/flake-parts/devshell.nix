{ inputs, ... }:
{
  imports = with inputs; [
    flake-root.flakeModule
    treefmt-nix.flakeModule
  ];
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = with config; [
          flake-root.devShell
          treefmt.build.devShell
        ];
        name = "shinx";
        meta.description = "NixOS & Nix Darwin & Home Manager 统一配置";
        packages = with pkgs; [
          just
          nixd
        ];
      };
    };
}
