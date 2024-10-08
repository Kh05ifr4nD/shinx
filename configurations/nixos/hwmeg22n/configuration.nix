{ hst, ... }:
{
  networking.hostName = hst;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      show-trace = true;
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    hostPlatform = "aarch64-linux";
  };
  system.stateVersion = "24.05";
  wsl = {
    enable = true;
    startMenuLaunchers = true;
    useWindowsDriver = true;
  };
}
