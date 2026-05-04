{ lib, ... }:
{
  options.modules.home.imports = lib.mkOption {
    default = [ ];
    description = "Additional Home Manager imports to append for the primary user";
    type = lib.types.listOf lib.types.anything;
  };
}
