{ ... }:
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
          hooks = {
            check-merge-conflicts.enable = true;
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
            treefmt = {
              enable = true;
              package = config.treefmt.build.wrapper;
              verbose = true;
            };
            trim-trailing-whitespace.enable = true;
          };
        };
      };
    };
}
