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
    homebrew-muxy-app-tap
    ;
  homebrewCurlConfig = pkgs.writeText "homebrew-curlrc" ''
    connect-timeout = 20
    retry-all-errors
    retry-connrefused
    retry-delay = 5
  '';
  homebrewNetworkEnv = {
    HOMEBREW_BUNDLE_JOBS = "1";
    HOMEBREW_CURL_RETRIES = "8";
    HOMEBREW_CURLRC = "${homebrewCurlConfig}";
    HOMEBREW_DOWNLOAD_CONCURRENCY = "1";
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
    casks = [
      "brewforge/chinese/gui-for-singbox"
      "cc-switch"
      "chatgpt"
      "codex-app"
      "cog-app"
      "ghostty"
      "homebrew/cask/onedrive"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "mos"
      "muxy"
      "obs"
      "obsidian"
      "opencode-desktop"
      "orbstack"
      "qq"
      "steam"
      "tailscale-app"
      "tencent-meeting"
      "utm"
      "visual-studio-code"
      "vlc"
      "wechat"
      "wetype"
      "zen"
      "zotero"
    ];
    enable = true;
    global.autoUpdate = false;
    masApps = {
      "PDFgear: PDF Editor & Reader" = 6469021132;
      "沉浸式翻譯" = 6447957425;
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
    enableRosetta = true;
    mutableTaps = false;
    taps = {
      "brewforge/homebrew-chinese" = homebrew-brewforge-chinese;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-core" = homebrew-core;
      "muxy-app/homebrew-tap" = homebrew-muxy-app-tap;
    };
    user = user.name;
  };
}
