{ userName }:
{
  "id" = {
    relPath = "/id.age";
    agePerms = {
      mode = "0600";
      owner = userName;
    };
  };

  "git-signing.key.conf" = {
    relPath = "/git/signing.key.conf.age";
    agePerms = {
      mode = "0600";
      owner = userName;
    };
  };

  "ssh-config.github.conf" = {
    relPath = "/ssh/config.github.conf.age";
    agePerms = {
      mode = "0644";
      owner = "root";
    };
  };

  # Optional: only required when modules.sshd.enable = true (see requirements.nix).
  "ssh-authorized-keys" = {
    relPath = "/ssh/authorized_keys.age";
    agePerms = {
      mode = "0644";
      owner = "root";
    };
  };
}
