{
  flake,
  ...
}:

{
  imports = [
    flake.inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;

    policies = {
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
    };

    profiles.default = {
      id = 0;
      isDefault = true;
      settings = {
        "browser.shell.checkDefaultBrowser" = false;
        "browser.tabs.warnOnClose" = false;
        "zen.welcome-screen.seen" = true;
      };
    };
  };
}
