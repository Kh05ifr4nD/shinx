{ flake, ... }:
let
  inherit (flake.config) user;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "/home/${user.name}/.ssh/github_ed25519";
        user = user.git-name;
      };
    };
  };
}
