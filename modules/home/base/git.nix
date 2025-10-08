{ flake, lib, ... }:
let
  inherit (flake.config) user;
  inherit (lib) mkIf mkMerge;
  hasSigningKey = user.gpg-key != null && user.gpg-key != "";
in
{
  programs = {
    git = mkMerge [
      {
        enable = true;
        extraConfig = {
          core = {
            autocrlf = "input";
            editor = "hx";
          };
          init.defaultBranch = "main";
          pull.rebase = "true";
          push.autoSetupRemote = true;
        };
        ignores = [
          "*~"
          "*.swp"
        ];
        lfs.enable = true;
        userEmail = user.email;
        userName = user.git-name;
      }
      (mkIf hasSigningKey {
        extraConfig = {
          commit.gpgsign = true;
          gpg.format = "openpgp";
          tag.gpgsign = true;
        };
        signing.key = user.gpg-key;
      })
    ];
    gitui.enable = true;
  };
}
