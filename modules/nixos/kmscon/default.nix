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
  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [
      {
        name = "Maple Mono NF CN";
        package = pkgs.maple-font."NF-CN";
      }
    ];
    extraOptions = [
      "--xkb-layout=us"
      "--locale=${locale}"
    ];
    extraConfig = "font-size=18";
  };

  systemd.services."kmsconvt@${kmsconTty}" = {
    enable = true;
    wantedBy = [ "getty.target" ];
  };

  systemd.services."getty@${kmsconTty}".enable = lib.mkForce false;

  console = {
    packages = [ pkgs.terminus_font ];
    font = "Lat2-Terminus16";
  };
}
