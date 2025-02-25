{ inputs, ... }:
{
  imports = with inputs; [
    treefmt-nix.flakeModule
  ];
  perSystem =
    { ... }:
    {
      treefmt.config = {
        programs = {
          just.enable = true;
          mdformat.enable = true;
          nixpkgs-fmt.enable = true;
          shellcheck.enable = true;
          taplo.enable = true;
        };
      };
    };
}
