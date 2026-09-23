{ lib, pkgs, ... }:
let
  ghosttyCommand =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/run/current-system/sw/bin/nu"
    else
      "${pkgs.nushell}/bin/nu";
in
{
  home.sessionVariables.TERMINAL = "ghostty";

  programs.ghostty = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
    settings = {
      auto-update = "off";
      command = ghosttyCommand;
      confirm-close-surface = false;
      font-family = "Maple Mono NF CN";
      font-size = 15;
      macos-option-as-alt = "left";
      quit-after-last-window-closed = true;
      shell-integration = "nushell";
      shell-integration-features = "ssh-env,ssh-terminfo";
      window-save-state = "always";
    };
  };
}
