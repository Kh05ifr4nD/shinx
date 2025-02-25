{ flake, ... }:
let
  inherit (flake.config) user;
in
{
  programs = {
    git = {
      aliases = {
        ci = "commit";
      };
      enable = true;
      extraConfig = {
        core = {
          autocrlf = "input";
          editor = "hx";
        };
        init.defaultBranch = "main";
        pull.rebase = "true";
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
    };
    gitui = {
      enable = true;
    };
  };
}
