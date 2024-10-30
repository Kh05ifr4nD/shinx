{
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware.graphics = {
    enable32Bit = true;
    enable = true;
    extraPackages = with pkgs; [ vaapiVdpau ];
  };
  services.xserver = {
    enable = true;
    videoDrivers = lib.mkDefault [ "nvidia" ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      # finegrained = true;
    };
    open = false;
    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
