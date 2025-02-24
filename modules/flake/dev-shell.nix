{ inputs, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = with config; [
          flake-root.devShell
          treefmt.build.devShell
        ];
        name = "shinx";
        meta.description = "NixOS & Nix Darwin & Home Manager 配置";
        packages = with pkgs; [
          nixd
        ];
        shellhook = ''
          ${config.pre-commit.installationScript}
        '';
      };
    };
}
