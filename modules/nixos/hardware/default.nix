{
  flake,
  lib,
  config,
  pkgs,
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
  };

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
    };
    fstrim.enable = true;
    fwupd.enable = true;
    irqbalance.enable = true;
    lm_sensors.enable = true;
  };
}
