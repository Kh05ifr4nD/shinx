{ lib, ... }:
{
  options.modules.home.imports = lib.mkOption {
    type = lib.types.listOf lib.types.anything;
    default = [ ];
    description = "Additional Home Manager imports to append for the primary user";
  };
}
