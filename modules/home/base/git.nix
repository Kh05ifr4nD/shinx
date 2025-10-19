{
  flake,
  lib,
  config,
  ...
}:
let
  inherit (flake.config) user;
in
{
  programs = {
    git = {
      enable = true;
      gitui = {
        enable = true;
      };
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
      includes = [
        { path = "/etc/agenix/git-signing.key.conf"; }
      ];
      lfs = {
        enable = true;
      };
      settings = {
        extraConfig = {
          core = {
            autocrlf = "input";
            editor = "hx";
          };
          commit.gpgsign = true;
          gpg.format = "openpgp";
          init.defaultBranch = "main";
          pull.rebase = "true";
          push.autoSetupRemote = true;
          tag.gpgsign = true;
        };
        user = {
          email = user.email;
          name = user.git-name;
        };
      };
    };
  };
}
