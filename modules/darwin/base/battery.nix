{
  lib,
  pkgs,
  ...
}:

let
  batteryPreferences = {
    acDisplaySleepMinutes = 16;
    acHibernateMode = 3;
    acLowPowerMode = false;
    acPowerNap = false;
    acSleepMinutes = 16;
    acTcpKeepAlive = true;
    acTtysKeepAwake = true;
    batteryDisplaySleepMinutes = 5;
    batteryHibernateMode = 25;
    batteryLowPowerMode = true;
    batteryPowerNap = false;
    batterySleepMinutes = 10;
    batteryTcpKeepAlive = false;
    batteryTtysKeepAwake = false;
    optimizeVideoStreamingOnBattery = false;
    reduceBrightnessOnBattery = true;
    wakeForNetworkOnAC = false;
  };

  boolToPmset = value: if value then "1" else "0";

  applyBatteryPreferences = pkgs.writeShellScript "apply-battery-preferences" ''
    set -u

    pmset="/usr/bin/pmset"
    defaults="/usr/bin/defaults"

    "$pmset" -b powermode 0 2>/dev/null || true
    "$pmset" -c powermode 0 2>/dev/null || true
    "$pmset" -b lowpowermode ${boolToPmset batteryPreferences.batteryLowPowerMode} 2>/dev/null || true
    "$pmset" -c lowpowermode ${boolToPmset batteryPreferences.acLowPowerMode} 2>/dev/null || true

    "$pmset" -b lessbright ${boolToPmset batteryPreferences.reduceBrightnessOnBattery} 2>/dev/null || true

    "$pmset" -b hibernatemode ${toString batteryPreferences.batteryHibernateMode} 2>/dev/null || true
    "$pmset" -c hibernatemode ${toString batteryPreferences.acHibernateMode} 2>/dev/null || true
    "$pmset" -b ttyskeepawake ${boolToPmset batteryPreferences.batteryTtysKeepAwake} 2>/dev/null || true
    "$pmset" -c ttyskeepawake ${boolToPmset batteryPreferences.acTtysKeepAwake} 2>/dev/null || true

    "$pmset" -c displaysleep ${toString batteryPreferences.acDisplaySleepMinutes} 2>/dev/null || true
    "$pmset" -b displaysleep ${toString batteryPreferences.batteryDisplaySleepMinutes} 2>/dev/null || true
    "$pmset" -c sleep ${toString batteryPreferences.acSleepMinutes} 2>/dev/null || true
    "$pmset" -b sleep ${toString batteryPreferences.batterySleepMinutes} 2>/dev/null || true

    "$pmset" -c womp ${boolToPmset batteryPreferences.wakeForNetworkOnAC} 2>/dev/null || true
    "$pmset" -b womp 0 2>/dev/null || true

    "$pmset" -c powernap ${boolToPmset batteryPreferences.acPowerNap} 2>/dev/null || true
    "$pmset" -b powernap ${boolToPmset batteryPreferences.batteryPowerNap} 2>/dev/null || true
    "$pmset" -c tcpkeepalive ${boolToPmset batteryPreferences.acTcpKeepAlive} 2>/dev/null || true
    "$pmset" -b tcpkeepalive ${boolToPmset batteryPreferences.batteryTcpKeepAlive} 2>/dev/null || true

    "$defaults" write /Library/Preferences/.GlobalPreferences.plist \
      com.apple.coremedia.optimizeVideoStreamingOnBattery \
      -bool ${if batteryPreferences.optimizeVideoStreamingOnBattery then "true" else "false"}

    /usr/bin/killall cfprefsd 2>/dev/null || true
  '';
in
{
  power.sleep = {
    allowSleepByPowerButton = true;
    harddisk = 10;
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "configuring battery preferences..."
    ${applyBatteryPreferences}
  '';
}
