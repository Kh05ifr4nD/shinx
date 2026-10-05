{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake.config) user;
  inherit (flake.inputs)
    homebrew-brewforge-chinese
    homebrew-cask
    homebrew-core
    homebrew-stablyai-orca
    ;
  homebrewCurlConfig = pkgs.writeText "homebrew-curlrc" ''
    connect-timeout = 12
    retry-all-errors
    retry-connrefused
    retry-delay = 4
  '';
  homebrewNetworkEnv = {
    HOMEBREW_CURL_RETRIES = "4";
    HOMEBREW_CURLRC = "${homebrewCurlConfig}";
    HOMEBREW_DOWNLOAD_CONCURRENCY = "4";
  };
  proxyEnv = import ../../proxy-env.nix { inherit lib; };
in
{
  imports = [
    flake.inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  homebrew = {
    brews = [
      "mas"
    ];
    caskArgs.input_methoddir = "/Users/${user.name}/Library/Input Methods";
    casks = [
      "brewforge/chinese/gui-for-singbox"
      "stablyai/orca/orca"
      "chatgpt"
      # "cog-app"
      "cursor"
      "donut"
      "ghostty"
      "hammerspoon"
      "mos"
      # "obs"
      "obsidian"
      "orbstack"
      "qq"
      "steam"
      "tencent-meeting"
      # "utm"
      "visual-studio-code"
      "vlc"
      "wetype"
      # "zen"
      "zotero"
    ];
    enable = true;
    greedyCasks = true;
    global.autoUpdate = false;
    masApps = {
      "Imp Translate" = 6764317525;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      "OneDrive" = 823766827;
      "Tailscale" = 1475387142;
      "WeChat" = 836500024;
    };
    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      extraEnv = proxyEnv // homebrewNetworkEnv;
      upgrade = true;
    };
    taps = builtins.attrNames config.nix-homebrew.taps;
  };

  nix-homebrew = {
    autoMigrate = false;
    enable = true;
    mutableTaps = false;
    taps = {
      "brewforge/homebrew-chinese" = homebrew-brewforge-chinese;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-core" = homebrew-core;
      "stablyai/homebrew-orca" = homebrew-stablyai-orca;
    };
    user = user.name;
  };
}
