# Edit this configuration file to define what should be installed on your system. Help is available in the configuration.nix(5) man page, on https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ ... }:
{
  # 全局已默认启用机密模块，无需重复开启

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = false;
      };
      grub = {
        configurationLimit = 10;
        enable = true;
        efiSupport = true;
        devices = [ "nodev" ];
        useOSProber = true;
      };
    };

    supportedFilesystems = [
      "btrfs"
      "ntfs"
    ];
  };
  time.hardwareClockInLocalTime = true;
}
