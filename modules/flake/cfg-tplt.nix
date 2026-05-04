{ lib, ... }:
{
  options = {
    user = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options = {
          email = lib.mkOption {
            description = "Email for use in Git";
            type = lib.types.str;
          };
          full-name = lib.mkOption {
            description = "Full name for use in Git";
            type = lib.types.str;
          };
          git-name = lib.mkOption {
            description = "Name for use in Git";
            type = lib.types.str;
          };
          name = lib.mkOption {
            description = "User name as shown by `id -un`";
            type = lib.types.str;
          };
        };
      };
    };
  };
}
