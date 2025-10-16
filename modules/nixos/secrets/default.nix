{
  lib,
  config,
  pkgs,
  flake,
  ...
}:
with lib;
let
  inherit (flake) inputs;
  flakeConfig = flake.config;
  agenix = inputs.agenix;
  mysecrets = inputs.mysecrets or null;
  hostname = config.networking.hostName;
  hostDir = if mysecrets != null then mysecrets + "/${hostname}" else null;

  cfg = config.modules.secrets;

  userName = flakeConfig.user.name;

  user_readable = {
    mode = "0600";
    owner = userName;
  };
in
{
  imports = [
    agenix.nixosModules.default
    ./requirements.nix
  ];

  options.modules.secrets = {
    user.enable = mkEnableOption "Enable user-level secrets (SSH/Git/Nix tokens)";
    preservation.enable = mkEnableOption "Use persistent age identity path when preservation is enabled";
  };

  config = mkIf cfg.user.enable (mkMerge [
    {
      environment.systemPackages = [
        agenix.packages."${pkgs.system}".default
      ];

      age.identityPaths =
        let
          base = "/etc/ssh/id";
          prefix = lib.optionalString cfg.preservation.enable "/persistent";
        in
        [ "${prefix}${base}" ];

      # Automatically include Nix access tokens into nix if present
      nix.extraOptions = mkIf (config.age.secrets ? "nix-access-tokens") (mkAfter ''
        !include ${config.age.secrets."nix-access-tokens".path}
      '');
    }

    {
      age.secrets = {
        "id" = ({ file = hostDir + "/id.age"; } // user_readable);
        "git-signing.key.conf" = ({ file = hostDir + "/git/signing.key.conf.age"; } // user_readable);
        "ssh-config.github.conf" = {
          file = hostDir + "/ssh/config.github.conf.age";
          mode = "0644";
          owner = "root";
        };
      };
    }

    (
      let
        tokens = if mysecrets != null then mysecrets + "/nix-access-tokens.age" else null;
      in
      mkIf (tokens != null && builtins.pathExists tokens) {
        age.secrets."nix-access-tokens" = ({ file = tokens; } // user_readable);
      }
    )
    {
      environment.etc = {
        "agenix/id" = mkIf (config.age.secrets ? "id") {
          source = config.age.secrets."id".path;
          mode = "0600";
          user = userName;
        };

        # Make nix access tokens available to the user if present
        "agenix/nix-access-tokens" = mkIf (config.age.secrets ? "nix-access-tokens") {
          source = config.age.secrets."nix-access-tokens".path;
          mode = "0640";
          user = userName;
        };

        # Only create include files if corresponding secrets are defined
        "agenix/git-signing.key.conf" = mkIf (config.age.secrets ? "git-signing.key.conf") {
          source = config.age.secrets."git-signing.key.conf".path;
          mode = "0644";
        };

        # Secret-provided ssh config snippet (client-only)
        "agenix/ssh.d/github.conf" = mkIf (config.age.secrets ? "ssh-config.github.conf") {
          source = config.age.secrets."ssh-config.github.conf".path;
          mode = "0644";
        };
      };
    }
  ]);
}
