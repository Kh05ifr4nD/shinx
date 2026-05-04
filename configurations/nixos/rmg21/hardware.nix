{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [
        "amdgpu"
        "nvidia"
        "nvidia-uvm"
        "nvidia_drm"
        "nvidia_modeset"
      ];
    };
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      efi = {
        canTouchEfiVariables = false;
      };
      grub = {
        configurationLimit = 10;
        devices = [ "nodev" ];
        enable = true;
        efiSupport = true;
        useOSProber = true;
      };
    };
    supportedFilesystems = [
      "btrfs"
      "ntfs"
    ];
  };
  fileSystems."/run/media/meandssh" = {
    device = "/dev/disk/by-id/nvme-WD_PC_SN540_SDDPNPF-512G_230129805588-part3";
    fsType = "ntfs3";
    options = [
      "async"
      "discard"
      "force"
      "prealloc"
      "ro"
      "sys_immutable"
      "windows_names"
    ];
  };
  time.hardwareClockInLocalTime = true;
}
