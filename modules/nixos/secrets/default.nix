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
  agenix = inputs.agenix;
  cfg = config.modules.secrets;
  flakeConfig = flake.config;
  hostDir = if mysecrets != null then mysecrets + "/${hostname}" else null;
  hostname = config.networking.hostName;
  mysecrets = inputs.mysecrets or null;
  userName = flakeConfig.user.name;
  specs = import ./specs.nix { inherit userName; };
  names = builtins.attrNames specs;
in
{
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix" && f != "specs.nix") (attrNames (readDir ./.)))
    ++ [
      agenix.nixosModules.default
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

      nix.extraOptions = mkIf (config.age.secrets ? "nix-access-tokens") (mkAfter ''
        !include ${config.age.secrets."nix-access-tokens".path}
      '');
    }

    {
      age.secrets = builtins.listToAttrs (
        map (name: {
          name = name;
          value = ({ file = hostDir + specs.${name}.relPath; } // specs.${name}.agePerms);
        }) names
      );
    }

    (
      let
        tokens = if mysecrets != null then mysecrets + "/nix-access-tokens.age" else null;
      in
      mkIf (tokens != null && builtins.pathExists tokens) {
        age.secrets."nix-access-tokens" = (
          {
            file = tokens;
          }
          // {
            mode = "0600";
            owner = userName;
          }
        );
      }
    )
    {
      environment.etc = {
        "agenix/id" = mkIf (config.age.secrets ? "id") {
          source = config.age.secrets."id".path;
          mode = "0600";
          user = userName;
        };

        "agenix/git-signing.key.conf" = mkIf (config.age.secrets ? "git-signing.key.conf") {
          source = config.age.secrets."git-signing.key.conf".path;
          mode = "0644";
        };

        "agenix/ssh.d/github.conf" = mkIf (config.age.secrets ? "ssh-config.github.conf") {
          source = config.age.secrets."ssh-config.github.conf".path;
          mode = "0644";
        };

        # Make nix access tokens available to the user if present
        "agenix/nix-access-tokens" = mkIf (config.age.secrets ? "nix-access-tokens") {
          source = config.age.secrets."nix-access-tokens".path;
          mode = "0640";
          user = userName;
        };
      };
    }

    {
      system.activationScripts.secrets-verify = {
        deps = [ "agenix" ];
        text =
          let
            secrets = map (
              name:
              let
                entry = builtins.getAttr name config.age.secrets;
                path = entry.path;
                expMode = lib.removePrefix "0" specs.${name}.agePerms.mode; # 0600 -> 600
                expOwner = specs.${name}.agePerms.owner;
              in
              ''
                if [ ! -s "${path}" ]; then
                  echo "[secrets] ERROR: ${name} 未成功解密或为空：${path}" >&2
                  exit 1
                fi
                set -- $(/run/current-system/sw/bin/stat -c '%a %U' "${path}")
                actualMode="$1"; actualOwner="$2"
                if [ "$actualMode" != "${expMode}" ] || [ "$actualOwner" != "${expOwner}" ]; then
                  echo "[secrets] ERROR: ${name} 权限/所有者不匹配，期望 ${expOwner}:${expMode} 实际 $actualOwner:$actualMode（${path}）" >&2
                  exit 1
                fi
              ''
            ) names;
          in
          lib.concatStringsSep "\n" (
            [
              ''set -euo pipefail''
            ]
            ++ secrets
          );
      };
    }
  ]);
}
