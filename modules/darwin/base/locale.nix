{
  time.timeZone = "Asia/Hong_Kong";

  system.defaults = {
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
    };

    CustomUserPreferences.NSGlobalDomain = {
      AppleFirstWeekday = {
        gregorian = 2;
      };
      AppleICUDateFormatStrings = {
        "1" = "yyyy-MM-dd";
        "2" = "yyyy-MM-dd";
        "3" = "yyyy-MM-dd";
        "4" = "yyyy-MM-dd EEEE";
      };
      AppleICUTimeFormatStrings = {
        "1" = "HH:mm";
        "2" = "HH:mm:ss";
        "3" = "HH:mm:ss z";
        "4" = "HH:mm:ss zzzz";
      };
      AppleLanguages = [
        "zh-Hans-CN"
        "en-US"
        "zh-Hant-HK"
      ];
      AppleLocale = "zh_HK@currency=HKD";
    };

    menuExtraClock = {
      FlashDateSeparators = false;
      IsAnalog = false;
      Show24Hour = true;
      ShowAMPM = false;
      ShowDate = 1;
      ShowDayOfMonth = true;
      ShowDayOfWeek = true;
      ShowSeconds = false;
    };
  };
}
