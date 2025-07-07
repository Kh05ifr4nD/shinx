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
  };
}
