{ lib, ... }:

{
  system = {
    activationScripts.postActivation.text = lib.mkAfter ''
      echo >&2 "configuring macOS software update automation..."
      defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
      defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool false
      defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool false
      defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true
      defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
      defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool false
    '';

    defaults.SoftwareUpdate = {
      AutomaticallyInstallMacOSUpdates = false;
    };
  };
}
