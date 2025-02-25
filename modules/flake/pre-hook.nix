{ inputs, ... }:
{
  imports = with inputs; [
    git-hooks-nix.flakeModule
  ];
  perSystem =
    { pkgs, ... }:
    {
      pre-commit.settings = {
        hooks = {
          clippy.enable = true;
          treefmt = {
            enable = true;
            settings.formatters = with pkgs; [
              just
              nixpkgs-fmt
            ];
          };
        };
      };
    };
}
