{
  lib,
  config,
  flake,
  ...
}:
let
  inherit (flake.config) user;
  cfg = config.modules.sshd or { };
  secretName = cfg.authorizedKeysSecretName or "ssh-authorized-keys";
in
{
  options.modules.sshd = {
    user = lib.mkOption {
      type = lib.types.str;
      default = user.name;
      description = "Local user to authorize for SSH login.";
    };
    authorizedKeysSecretName = lib.mkOption {
      type = lib.types.str;
      default = "ssh-authorized-keys";
      description = "Name of the age secret containing authorized_keys contents.";
    };
  };

  config = {
    assertions = [
      {
        assertion = (config.age.secrets ? "${secretName}");
        message = "启用了 SSH 服务器，但未提供密文 ${secretName}（请在私密仓库为该主机创建 ssh/authorized_keys.age）";
      }
    ];

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
  };
}
