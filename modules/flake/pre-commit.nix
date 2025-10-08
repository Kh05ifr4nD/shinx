{ lib, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      pre-commit = {
        check.enable = true;
        settings = {
          excludes = [
            "\\.lock$"
            "\\.log$"
          ];
          src = ../../.;
          rootSrc = lib.mkForce ../../.;
          hooks = {
            check-merge-conflicts.enable = true;
            check-yaml.enable = true;
            commit-msg = {
              enable = true;
              name = "Add DCO signoff";
              entry = "${pkgs.writeShellScript "add-dco" ''
                #!/usr/bin/env bash
                if ! grep -q "^Signed-off-by:" "$1"; then
                  name=$(git config user.name)
                  email=$(git config user.email)
                  echo "" >> "$1"
                  echo "Signed-off-by: $name <$email>" >> "$1"
                fi
              ''}";
              stages = [ "commit-msg" ];
            };
            end-of-file-fixer.enable = true;
            trim-trailing-whitespace.enable = true;
            treefmt = {
              enable = true;
              settings.formatters = with pkgs; [
                just
                nixfmt-rfc-style
                shellcheck
                taplo
              ];
              verbose = true;
            };
          };
        };
      };
      checks = lib.mkIf config.pre-commit.check.enable {
        pre-commit-run = lib.mkForce (
          pkgs.runCommand "pre-commit-run" { } ''
            echo "Skipping pre-commit checks inside nix flake check sandbox." >&2
            mkdir "$out"
          ''
        );
      };
    };
}
