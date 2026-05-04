{ lib, ... }:
{
  options.modules.home.stateVersion = lib.mkOption {
    default = "26.05";
    description = "Home Manager state version for the primary user";
    type = lib.types.str;
  };
}
