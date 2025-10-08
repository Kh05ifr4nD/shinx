{ lib, ... }:
{
  options = {
    user = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options = {
          email = lib.mkOption {
            type = lib.types.str;
            description = "Email for use in git";
          };
          full-name = lib.mkOption {
            type = lib.types.str;
            description = "Full name for use in git";
          };
          git-name = lib.mkOption {
            type = lib.types.str;
            description = "Name for use in git";
          };
          name = lib.mkOption {
            type = lib.types.str;
            description = "User name as shown by `id -un`";
          };
          pub-key = lib.mkOption {
            type = lib.types.str;
            description = "Public key";
          };
          gpg-key = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "GPG key ID for signing commits";
          };
        };
      };
    };

    secrets = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = ''
        Decrypted secret values sourced from an encrypted flake. Secrets are
        discovered via the SHINX_SECRETS_FILE environment variable, an optional
        `secrets` flake input or repository-local cfg.secrets.yaml instances
        (preferring secrets/cfg.secrets.yaml).
      '';
    };

    secretsMeta = lib.mkOption {
      default = {
        available = false;
        format = "missing";
        path = null;
        origin = null;
        description = null;
        fallback = true;
        fallbackReason = "missing";
      };
      type = lib.types.submodule {
        options = {
          available = lib.mkOption {
            type = lib.types.bool;
            description = "Whether a cfg.secrets.yaml source was located and successfully decoded.";
          };

          format = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "Decoder used for the secret source (e.g. sops or json).";
          };

          path = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "Stringified path to the resolved cfg.secrets.yaml candidate.";
          };

          origin = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "Where the secret candidate originated (environment, flake-input, worktree or repository).";
          };

          description = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "Human-friendly description of the matched candidate.";
          };

          fallback = lib.mkOption {
            type = lib.types.bool;
            description = "True when a non-primary decoding path or placeholder values were used.";
          };

          fallbackReason = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "Reason describing why a fallback path was taken.";
          };

          warning = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Warning message emitted when decoding failed or a placeholder was used.";
          };
        };
      };
      description = ''
        Metadata describing how the cfg.secrets.yaml payload was located and
        decoded. Helpful for debugging fallback behaviour and ensuring secrets
        are sourced from the intended location.
      '';
    };
  };
}
