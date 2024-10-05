{ pkgs, ... }:
{
  networking.hostName = "hwmeg22n";
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
      allowed-users = [ "meandssh" ];
      experimental-features = "nix-command flakes";
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [
        "meandssh"
        "root"
      ];
    };
  };
  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "24.05";
  users.users.meandssh = {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    shell = pkgs.nushell;
  };
  wsl = {
    enable = true;
    defaultUser = "meandssh";
    startMenuLaunchers = true;
    useWindowsDriver = true;
  };
}
