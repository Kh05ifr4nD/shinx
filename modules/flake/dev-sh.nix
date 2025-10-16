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
        name = "shinx";
        meta.description = "Home Manager & Nix Darwin & NixOS Configurations Based on https://github.com/srid/nixos-unified";
        packages = with pkgs; [
          nixd
          nixfmt-rfc-style
        ];
        shellhook = '''';
      };
    };
}
