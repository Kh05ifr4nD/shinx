{ flake, ... }:
let
  inherit (flake.config) user;
in
{
  imports = [
    flake.inputs.sops-nix.darwinModules.sops
  ];

  sops = {
    age = {
      generateKey = false;
      keyFile = "/Users/${user.name}/Library/Application Support/sops/age/keys.txt";
      sshKeyPaths = [ ];
    };
    defaultSopsFile = ../../../secrets/aa3448.yaml;
    gnupg.sshKeyPaths = [ ];
    secrets."git-signing/key.conf" = {
      mode = "0400";
      owner = user.name;
    };
    secrets."gpg/privateKey.asc" = {
      mode = "0400";
      owner = user.name;
    };
    secrets."ssh/githubPrivateKey" = {
      mode = "0400";
      owner = user.name;
    };
  };
}
