{ flake, ... }:
let
  inherit (flake.config) user;
in
{
  programs = {
    git = {
      enable = true;
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
      ignores = [
        "*~"
        "*.swp"
      ];
      lfs = {
        enable = true;
      };
      userEmail = user.email;
      userName = user.git-name;
      signing.key = user.gpg-key;
    };
    gitui = {
      enable = true;
    };
  };
}
