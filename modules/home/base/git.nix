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
      ignores = [
        "*~"
        "*.swp"
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
        userEmail = user.email;
        userName = user.git-name;
      };
    };
    gitui = {
      enable = true;
    };
  };
}
