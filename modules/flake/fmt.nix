{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      treefmt.config = {
        projectRootFile = "flake.nix";
        settings.global.excludes = [
          ".devenv/**"
          ".direnv/**"
          ".DS_Store"
          ".git/**"
          ".idea/**"
          "**/.git-*/**"
          "**/*.log"
          "result*"
        ];
        programs = {
          just.enable = true;
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };
          shellcheck.enable = true;
          taplo.enable = true;
        };
      };
    };
}
