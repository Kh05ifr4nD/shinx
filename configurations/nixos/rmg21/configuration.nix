# Edit this configuration file to define what should be installed on your system. Help is available in the configuration.nix(5) man page, on https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ ... }:
{
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
  };
  time.hardwareClockInLocalTime = true;
}
