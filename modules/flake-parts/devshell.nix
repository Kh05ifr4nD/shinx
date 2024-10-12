{ ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = [
          config.flake-root.devShell
          config.treefmt.build.devShell
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
