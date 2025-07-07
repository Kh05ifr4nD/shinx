{
  ...
}:
{
  services.xserver.enable = true;
  services.displayManager.sddm = {
    autoNumlock = true;
    enable = true;
    enableHidpi = true;
    wayland = {
      enable = true;
    };
  };
  services.desktopManager.plasma6.enable = true;
}
