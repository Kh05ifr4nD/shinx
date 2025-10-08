{
  flake,
  lib,
  config,
  pkgs,
  options,
  ...
}:
let
  inherit (flake) inputs;
in
{
  boot.supportedFilesystems = lib.mkDefault [
    "btrfs"
    "ntfs"
  ];
  programs.coolercontrol.enable = true;

  hardware = {
    cpu = {
      amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
    enableRedistributableFirmware = true;
  }
  // lib.optionalAttrs (lib.hasAttrByPath [ "hardware" "sensors" "lm-sensors" ] options) {
    sensors.lm-sensors.enable = true;
  };

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };
    fstrim.enable = true;
    fwupd.enable = true;
    irqbalance.enable = true;
  }
  // lib.optionalAttrs (lib.hasAttrByPath [ "services" "lm_sensors" ] options) {
    lm_sensors.enable = true;
  };
}
