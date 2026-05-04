{ ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = with config; [
          flake-root.devShell
          pre-commit.devShell
          treefmt.build.devShell
        ];
        meta.description = "Home Manager & Nix Darwin & NixOS Configurations Based on https://github.com/srid/nixos-unified";
        name = "shinx";
        packages = with pkgs; [
          age
          nixd
          nixfmt
          sops
        ];
        shellhook = "";
      };
    };
}
