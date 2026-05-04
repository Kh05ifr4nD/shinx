{ lib, pkgs, ... }:
let
  ghosttyCommand =
    if pkgs.stdenv.isDarwin then "/run/current-system/sw/bin/nu" else "${pkgs.nushell}/bin/nu";
in
{
  home.sessionVariables.TERMINAL = "ghostty";

  programs.ghostty = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isDarwin pkgs.ghostty-bin;
    settings = {
      command = ghosttyCommand;
      shell-integration = "nushell";
      window-save-state = "always";
    };
  };
}
