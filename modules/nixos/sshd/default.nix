{
  lib,
  config,
  flake,
  ...
}:
let
  inherit (flake.config) user;
  cfg = config.modules.sshd or { };
  secretAvailable =
    cfg.authorizedKeysSecretName != null
    && config ? sops
    && config.sops ? secrets
    && builtins.hasAttr cfg.authorizedKeysSecretName config.sops.secrets;
in
{
  options.modules.sshd = {
    enable = lib.mkEnableOption "OpenSSH server" // {
      default = true;
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = user.name;
      description = "Local user to authorize for SSH login.";
    };
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Plain public keys to authorize for SSH login.";
    };
    authorizedKeysSecretName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Name of the sops-nix secret containing authorized_keys contents.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = lib.mkDefault true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };

    users.users.${cfg.user}.openssh.authorizedKeys = {
      keys = cfg.authorizedKeys;
      keyFiles = lib.optional secretAvailable config.sops.secrets.${cfg.authorizedKeysSecretName}.path;
    };

    warnings = lib.optional (cfg.authorizedKeys == [ ] && !secretAvailable) ''
      modules.sshd is enabled without authorized keys. This is acceptable for retired hosts,
      but future hosts should set modules.sshd.authorizedKeys or modules.sshd.authorizedKeysSecretName with sops-nix.
    '';
  };
}
