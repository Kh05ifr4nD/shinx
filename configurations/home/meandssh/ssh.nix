{...}:{
  programs.ssh = {
    addKeysToAgent = true;
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "/home/meandssh/.ssh/github_ed25519";
        user = "Kh04ifr4nD";
      };
    };
  };
}
