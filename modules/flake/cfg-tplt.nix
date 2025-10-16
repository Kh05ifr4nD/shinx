{ lib, ... }:
{
  options = {
    user = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options = {
          email = lib.mkOption {
            type = lib.types.str;
            description = "Email for use in Git";
          };
          full-name = lib.mkOption {
            type = lib.types.str;
            description = "Full name for use in Git";
          };
          git-name = lib.mkOption {
            type = lib.types.str;
            description = "Name for use in Git";
          };
          name = lib.mkOption {
            type = lib.types.str;
            description = "User name as shown by `id -un`";
          };
        };
      };
    };
  };
}
