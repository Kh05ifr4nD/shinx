{ lib, pkgs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      mkShellApp =
        name: runtimeInputs: script:
        pkgs.writeShellApplication {
          inherit name runtimeInputs;
          text = script;
        };
    in
    {
      apps = {
        fmt-check = {
          type = "app";
          program =
            (mkShellApp "fmt-check" [ pkgs.nix ] ''
              set -euo pipefail
              nix --extra-experimental-features 'nix-command flakes' fmt -- --fail-on-change "$@"
            '').outPath
            + "/bin/fmt-check";
          meta.description = "Run treefmt via nix fmt and fail when code is not formatted.";
        };
        flake-check = {
          type = "app";
          program =
            (mkShellApp "flake-check" [ pkgs.nix ] ''
              set -euo pipefail
              nix --extra-experimental-features 'nix-command flakes' flake check --impure "$@"
            '').outPath
            + "/bin/flake-check";
          meta.description = "Execute nix flake check with the required experimental features enabled.";
        };
        secrets-smoke = {
          type = "app";
          program =
            (mkShellApp "secrets-smoke" [ pkgs.nix pkgs.python3 pkgs.age pkgs.sops ] ''
              set -euo pipefail
              python scripts/secrets_cli.py smoke "$@"
            '').outPath
            + "/bin/secrets-smoke";
          meta.description = "Verify the SOPS/Age toolchain by running the bundled smoke test.";
        };
      };
    };
}
