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
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "10m";
        ForwardAgent = false;
        HashKnownHosts = false;
        ServerAliveCountMax = 3;
        ServerAliveInterval = 0;
      };
      "github.com" = {
        HostName = "github.com";
        IdentitiesOnly = true;
        IdentityFile = [ "/run/secrets/ssh/githubPrivateKey" ];
        User = "git";
      };
      "tdx" = {
        ControlMaster = "no";
        ControlPath = "none";
        ControlPersist = "no";
        HostName = "100.64.89.99";
        IdentitiesOnly = true;
        IdentityFile = [ "~/.ssh/id_ed25519_${hostName}" ];
        PasswordAuthentication = "no";
        Port = 32226;
        PreferredAuthentications = "publickey";
        User = "ryh";
      };
    };
  };
}
