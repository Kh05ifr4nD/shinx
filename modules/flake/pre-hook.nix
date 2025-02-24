{ inputs, ... }:
{
  imports = with inputs; [
    git-hooks-nix.flakeModule
  ];
  perSystem =
    { ... }:
    {
      pre-commit.settings.hooks = {
        treefmt.enable = true;
      };
    };
}
