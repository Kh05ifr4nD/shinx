{ lib, pkgs, ... }:
let
  ghosttyCommand =
    if pkgs.stdenv.isDarwin then "/run/current-system/sw/bin/nu" else "${pkgs.nushell}/bin/nu";
in
{
  home.sessionVariables.TERMINAL = "ghostty";

  programs.ghostty = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isDarwin null;
    settings = {
      auto-update = "off";
      command = ghosttyCommand;
      confirm-close-surface = false;
      font-family = "Maple Mono NF CN";
      font-size = 14;
      quit-after-last-window-closed = true;
      shell-integration = "nushell";
      window-save-state = "always";
    };
  };
}
