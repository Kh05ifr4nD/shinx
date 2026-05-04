{
  flake,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (flake.config) user;
  hasGitSigning =
    osConfig ? sops
    && osConfig.sops ? secrets
    && builtins.hasAttr "git-signing/key.conf" osConfig.sops.secrets;
in
{
  programs = {
    git = {
      enable = true;
      ignores = [
        ".#"
        ".devenv/"
        ".direnv/"
        ".DS_Store"
        "*.log"
        "*.swo"
        "*.swp"
        "~"
        "result-*"
        "result"
      ];
      lfs = {
        enable = true;
      };
      settings = {
        core = {
          autocrlf = "input";
          editor = "hx";
        };
        gpg.program = "${pkgs.gnupg}/bin/gpg";
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        user = {
          email = user.email;
          name = user.git-name;
        };
      }
      // lib.optionalAttrs hasGitSigning {
        commit.gpgsign = true;
        include.path = "/run/secrets/git-signing/key.conf";
        tag.gpgsign = true;
      };
    };
  };
}
