{
  config,
  lib,
  pkgs,
  ...
}:

let
  kmsconTty = "tty1";
  locale = config.i18n.defaultLocale or "zh_CN.UTF-8";
in
{
  console = {
    packages = [ pkgs.terminus_font ];
    font = "Lat2-Terminus16";
  };
  services.kmscon = {
    enable = true;
    config = {
      font-name = "Maple Mono NF CN";
      font-size = 18;
    }
    // lib.optionalAttrs config.hardware.graphics.enable {
      hwaccel = true;
    };
    extraOptions = "--xkb-layout=us";
  };

  systemd.services = {
    "getty@${kmsconTty}".enable = lib.mkForce false;
    "kmsconvt@${kmsconTty}" = {
      enable = true;
      wantedBy = [ "getty.target" ];
      environment = {
        LANG = locale;
        LC_ALL = locale;
      };
    };
  };
}
