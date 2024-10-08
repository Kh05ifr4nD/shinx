{ ... }:
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
      userEmail = "meandSSH0219@gmail.com";
      userName = "Kh05ifr4nD";
    };
  };
}
