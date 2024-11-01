{...}:{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "/home/meandssh/.ssh/github_ed25519";
        user = "Kh05ifr4nD";
      };
    };
  };
}
