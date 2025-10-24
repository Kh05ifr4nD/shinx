{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [
        "amdgpu"
        "nvidia"
        "nvidia_modeset"
        "nvidia-uvm"
        "nvidia_drm"
      ];
    };
    extraModulePackages = [ ];
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_zen;
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
