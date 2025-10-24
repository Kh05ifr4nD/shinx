{
  flake,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  cfg = config.modules.hardware;
in
{
  options.modules.hardware = {
    coolercontrol.enable = lib.mkEnableOption "Enable CoolerControl";
    microcode.auto = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically enable CPU microcode updates based on firmware availability.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.coolercontrol.enable {
      programs.coolercontrol.enable = true;
    })

    (lib.mkIf cfg.microcode.auto {
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    })

    {
      services.fstrim.enable = lib.mkDefault true;
    }
  ];
}
