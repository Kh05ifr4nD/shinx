{
  flake,
  ...
}:
let
  inherit (flake.config) user;
  inherit (flake.inputs)
    homebrew-brewforge-chinese
    homebrew-cask
    homebrew-core
    ;
in
{
  imports = [
    flake.inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  homebrew = {
    brews = [ ];
    casks = [
      "brewforge/chinese/gui-for-singbox"
      "cc-switch"
      "cmux"
      "codex-app"
      "cog-app"
      "homebrew/cask/onedrive"
      "mos"
      "tailscale-app"
    ];
    enable = true;
    global.autoUpdate = false;
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = false;
    };
    taps = [
      "brewforge/chinese"
      "homebrew/cask"
      "homebrew/core"
    ];
  };

  nix-homebrew = {
    autoMigrate = false;
    enable = true;
    enableRosetta = true;
    mutableTaps = false;
    taps = {
      "brewforge/homebrew-chinese" = homebrew-brewforge-chinese;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-core" = homebrew-core;
    };
    user = user.name;
  };
}
