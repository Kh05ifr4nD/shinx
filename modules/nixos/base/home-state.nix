{ lib, ... }:
{
  options.modules.home.stateVersion = lib.mkOption {
    type = lib.types.str;
    description = "Home Manager stateVersion for the primary user (set per host)";
    default = "25.05";
  };
}
