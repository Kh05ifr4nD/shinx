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
    extraConfig = "font-size=18";
    extraOptions = "--xkb-layout=us";
    fonts = [
      {
        name = "Maple Mono NF CN";
        package = pkgs.maple-mono."NF-CN";
      }
    ];
    hwRender = true;
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
