{ pkgs, ... }:
{
  hardware.graphics.enable = true;
  i18n.defaultLocale = "zh_CN.UTF-8";
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
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    hostPlatform = "aarch64-linux";
  };
  system.stateVersion = "24.05";
  time.timeZone = "Asia/Shanghai";
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
