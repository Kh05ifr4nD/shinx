{ ... }:
{
  perSystem =
    { ... }:
    {
      treefmt.config = {
        programs = {
          just.enable = true;
          nixfmt.enable = true;
          shellcheck.enable = true;
          taplo.enable = true;
        };
      };
    };
}
