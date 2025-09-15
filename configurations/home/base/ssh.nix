{ flake, ... }:
let
  inherit (flake.config) user;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "/home/${user.name}/.ssh/github_ed25519";
        user = user.git-name;
      };
    };
  };
}
