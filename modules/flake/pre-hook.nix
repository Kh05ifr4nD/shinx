{ inputs, pkgs, ... }:
{
  imports = with inputs; [
    git-hooks-nix.flakeModule
  ];
  perSystem =
    { ... }:
    {
      pre-commit.settings = {
        hooks = {
          clippy.enable = true;
          treefmt.enable = true;
        };
        treefmt.formatters = with pkgs; [
          nixpkgs-fmt
        ];
      };
    };
}
