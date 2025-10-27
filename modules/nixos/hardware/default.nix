{ lib, config, ... }:
{
  config = {
    hardware = {
      cpu = {
        amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
      enableRedistributableFirmware = lib.mkDefault true;
    };
    services.fstrim.enable = lib.mkDefault true;
  };
}
