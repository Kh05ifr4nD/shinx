{
  flake,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    flake.inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isDarwin null;

    policies = {
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = true;
      RequestedLocales = [
        "zh-CN"
        "en-US"
      ];
    };

    profiles.default = {
      id = 0;
      isDefault = true;
      settings = {
        "browser.shell.checkDefaultBrowser" = false;
        "browser.tabs.warnOnClose" = false;
        "intl.accept_languages" = "zh-CN, zh, en-US, en";
        "intl.locale.requested" = "zh-CN";
        "signon.rememberSignons" = true;
        "zen.welcome-screen.seen" = true;
      };
    };
  };

  # Per-install profile key for the stable Home Manager app symlink.
  home.file."${config.home.homeDirectory}/Library/Application Support/Zen/installs.ini".text = ''
    [A5AEE217BC1DA2A6]
    Default=Profiles/default
    Locked=1
  '';
}
