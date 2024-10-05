{ ... }:
{
  programs = {
    git = {
      enable = true;
      userName = "Kh05ifr4nD";
      userEmail = "meandSSH0219@gmail.com";
      ignores = [
        "*~"
        "*.swp"
      ];
      aliases = {
        ci = "commit";
      };
      extraConfig = {
        init.defaultBranch = "main";
        # pull.rebase = "false";
      };
    };
  };
}
