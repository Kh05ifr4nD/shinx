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
  sshdUser =
    if (config ? modules && config.modules ? sshd && config.modules.sshd ? user) then
      config.modules.sshd.user
    else
      userName;
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
    verify = {
      enable = mkEnableOption "Verify secrets ownership and permissions via a systemd oneshot";
      strict = mkOption {
        type = types.bool;
        default = true;
        description = ''
          When true, the verification service fails on mismatches. When false,
          it only warns. Default is relaxed on WSL.
        '';
      };
    };
  };

  config = mkMerge [
    {
      modules.secrets.verify = {
        enable = mkDefault true;
        strict = mkDefault true;
      };
    }

    (mkIf cfg.user.enable (mkMerge [
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
        age.secrets =
          let
            presentNames = builtins.filter (
              n: mysecrets != null && builtins.pathExists (hostDir + specs.${n}.relPath)
            ) names;
          in
          builtins.listToAttrs (
            map (name: {
              name = name;
              value = ({ file = hostDir + specs.${name}.relPath; } // specs.${name}.agePerms);
            }) presentNames
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
            mode = "0644";
            user = userName;
          };

          "ssh/authorized_keys.d/${sshdUser}" = mkIf (config.age.secrets ? "ssh-authorized-keys") {
            source = config.age.secrets."ssh-authorized-keys".path;
            mode = "0644";
            user = "root";
          };
        };
      }

      # Post-boot verification as a robust oneshot. Does not block login.
      (mkIf cfg.verify.enable (
        let
          present = builtins.filter (n: config.age.secrets ? n) names;
          script = pkgs.writeShellScript "secrets-verify" (
            let
              checks = lib.concatStringsSep "\n" (
                map (
                  n:
                  let
                    path = (builtins.getAttr n config.age.secrets).path;
                    expMode = lib.removePrefix "0" specs.${n}.agePerms.mode;
                    expOwner = specs.${n}.agePerms.owner;
                  in
                  ''
                    if [ ! -s "${path}" ]; then
                      echo "[secrets] WARN: ${n} 未成功解密或为空：${path}" >&2
                      fail=$((fail+1))
                    else
                      set -- $("${pkgs.coreutils}/bin/stat" -c '%a %U' "${path}")
                      actualMode="$1"; actualOwner="$2"
                      if [ "$actualMode" != "${expMode}" ] || [ "$actualOwner" != "${expOwner}" ]; then
                        echo "[secrets] WARN: ${n} 权限/所有者不匹配，期望 ${expOwner}:${expMode} 实际 $actualOwner:$actualMode（${path}）" >&2
                        fail=$((fail+1))
                      fi
                    fi
                  ''
                ) present
              );
            in
            ''
              set -eu
              fail=0
              ${checks}
              if ${lib.boolToString cfg.verify.strict} && [ "$fail" -gt 0 ]; then
                echo "[secrets] 验证失败，总计 $fail 项不匹配" >&2
                exit 1
              fi
              exit 0
            ''
          );
        in
        {
          systemd.services.secrets-verify = {
            description = "Verify secrets ownership and permissions";
            wantedBy = [ "multi-user.target" ];
            after = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = script;
            };
          };
        }
      ))
    ]))
  ];
}
