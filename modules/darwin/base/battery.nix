{
  lib,
  pkgs,
  ...
}:

let
  batteryPreferences = {
    acSleepMinutes = 60;
    acDisplaySleepMinutes = 50;
    batterySleepMinutes = 30;
    batteryDisplaySleepMinutes = 25;
    batteryTcpKeepAlive = true;
    diskSleepMinutes = 10;
    lowPowerMode = false;
    optimizeVideoStreamingOnBattery = false;
    reduceBrightnessOnBattery = true;
    wakeForNetworkOnAC = true;
  };

  boolToPmset = value: if value then "1" else "0";

  applyBatteryPreferences = pkgs.writeShellScript "apply-battery-preferences" ''
    set -u

    pmset="/usr/bin/pmset"
    defaults="/usr/bin/defaults"

    "$pmset" -b powermode 0 2>/dev/null || true
    "$pmset" -c powermode 0 2>/dev/null || true
    "$pmset" -b lowpowermode ${boolToPmset batteryPreferences.lowPowerMode} 2>/dev/null || true
    "$pmset" -c lowpowermode ${boolToPmset batteryPreferences.lowPowerMode} 2>/dev/null || true

    "$pmset" -b lessbright ${boolToPmset batteryPreferences.reduceBrightnessOnBattery} 2>/dev/null || true

    "$pmset" -c displaysleep ${toString batteryPreferences.acDisplaySleepMinutes} 2>/dev/null || true
    "$pmset" -b displaysleep ${toString batteryPreferences.batteryDisplaySleepMinutes} 2>/dev/null || true
    "$pmset" -c sleep ${toString batteryPreferences.acSleepMinutes} 2>/dev/null || true
    "$pmset" -b sleep ${toString batteryPreferences.batterySleepMinutes} 2>/dev/null || true
    "$pmset" -a disksleep ${toString batteryPreferences.diskSleepMinutes} 2>/dev/null || true

    "$pmset" -c womp ${boolToPmset batteryPreferences.wakeForNetworkOnAC} 2>/dev/null || true
    "$pmset" -b womp 0 2>/dev/null || true

    "$pmset" -c tcpkeepalive 1 2>/dev/null || true
    "$pmset" -b tcpkeepalive ${boolToPmset batteryPreferences.batteryTcpKeepAlive} 2>/dev/null || true

    "$defaults" write /Library/Preferences/.GlobalPreferences.plist \
      com.apple.coremedia.optimizeVideoStreamingOnBattery \
      -bool ${if batteryPreferences.optimizeVideoStreamingOnBattery then "true" else "false"}

    /usr/bin/killall cfprefsd 2>/dev/null || true
  '';
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "configuring battery preferences..."
    ${applyBatteryPreferences}
  '';
}
