{
  osConfig,
  ...
}:
let
  hostName = osConfig.modules.host.name;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "10m";
        forwardAgent = false;
        hashKnownHosts = false;
        serverAliveCountMax = 3;
        serverAliveInterval = 0;
      };
      "github.com" = {
        hostname = "github.com";
        identitiesOnly = true;
        identityFile = [ "/run/secrets/ssh/githubPrivateKey" ];
        user = "git";
      };
      "tdx" = {
        controlMaster = "no";
        controlPath = "none";
        controlPersist = "no";
        extraOptions = {
          PasswordAuthentication = "no";
          PreferredAuthentications = "publickey";
        };
        hostname = "100.64.89.99";
        identitiesOnly = true;
        identityFile = [ "~/.ssh/id_ed25519_${hostName}" ];
        port = 32226;
        user = "ryh";
      };
    };
  };
}
