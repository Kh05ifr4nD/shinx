{ config, lib, ... }:
let
  cfg = config.modules.clt;
in
{
  options.modules.clt = {
    enable = lib.mkEnableOption "Xcode Command Line Tools management";

    autoInstall = lib.mkOption {
      default = false;
      description = "Install Command Line Tools through Apple softwareupdate when missing.";
      type = lib.types.bool;
    };

    autoSelect = lib.mkOption {
      default = true;
      description = "Select /Library/Developer/CommandLineTools when it exists.";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.checks.text = lib.mkBefore ''
      echo >&2 "checking Xcode Command Line Tools..."

      install_clt() {
        label="$(/usr/sbin/softwareupdate --list 2>&1 \
          | /usr/bin/awk -F': ' '/Label: Command Line Tools/ { print $2; exit }')"

        if [ -z "$label" ]; then
          echo >&2 ""
          echo >&2 "error: Xcode Command Line Tools are not installed, and softwareupdate did not report an installable CLT label."
          echo >&2 "Try manually:"
          echo >&2 "  xcode-select --install"
          echo >&2 "  softwareupdate --list"
          echo >&2 ""
          exit 1
        fi

        echo >&2 "installing Xcode Command Line Tools via softwareupdate:"
        echo >&2 "  $label"
        /usr/sbin/softwareupdate --install "$label"
      }

      if ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
        ${lib.optionalString cfg.autoInstall ''
          install_clt
        ''}
        ${lib.optionalString (!cfg.autoInstall) ''
          echo >&2 ""
          echo >&2 "error: Xcode Command Line Tools are not installed."
          echo >&2 "Install them before activating this host:"
          echo >&2 "  xcode-select --install"
          echo >&2 ""
          echo >&2 "Or install the exact update currently offered by Apple:"
          echo >&2 "  softwareupdate --list"
          echo >&2 "  sudo softwareupdate --install '<Command Line Tools label>'"
          echo >&2 ""
          exit 1
        ''}
      fi

      developer_dir="$(/usr/bin/xcode-select -p)"

      if [ -d /Library/Developer/CommandLineTools ] && [ "$developer_dir" != "/Library/Developer/CommandLineTools" ]; then
        ${lib.optionalString cfg.autoSelect ''
          echo >&2 "selecting Xcode Command Line Tools..."
          /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
          developer_dir="$(/usr/bin/xcode-select -p)"
        ''}
      fi

      if [ ! -d "$developer_dir" ]; then
        echo >&2 ""
        echo >&2 "error: xcode-select points to a missing developer directory:"
        echo >&2 "  $developer_dir"
        echo >&2 ""
        echo >&2 "Try:"
        echo >&2 "  sudo xcode-select --switch /Library/Developer/CommandLineTools"
        echo >&2 "or reinstall:"
        echo >&2 "  sudo rm -rf /Library/Developer/CommandLineTools"
        echo >&2 "  xcode-select --install"
        echo >&2 ""
        exit 1
      fi

      if ! /usr/bin/xcrun --sdk macosx --show-sdk-path >/dev/null 2>&1; then
        echo >&2 ""
        echo >&2 "error: xcrun cannot locate the macOS SDK."
        echo >&2 "Current developer dir:"
        echo >&2 "  $developer_dir"
        echo >&2 ""
        echo >&2 "Try:"
        echo >&2 "  sudo xcode-select --switch /Library/Developer/CommandLineTools"
        echo >&2 ""
        exit 1
      fi
    '';
  };
}
