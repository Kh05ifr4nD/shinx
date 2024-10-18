{ hst, ... }:
{
  networking.hostName = hst;
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
  wsl = {
    enable = true;
    startMenuLaunchers = true;
    useWindowsDriver = true;
  };
}
