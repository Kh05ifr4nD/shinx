{
  config,
  lib,
  pkgs,
  ...
}:

let
  kmsconTty = "tty1";
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
      "--locale=zh_CN.UTF-8"
    ];
    extraConfig = "font-size=18";
  };

  # kmscon ships as a templated unit (kmsconvt@.service). Enabling the
  # tty1 instance here ensures systemd wires it into getty.target just as it
  # would for the classic getty@tty1 unit, so login prompts appear at the same
  # boot milestone. We also explicitly mask getty@tty1 to avoid systemd
  # starting both services on the same VT and racing for control of the
  # framebuffer; kmscon needs exclusive ownership to render CJK glyphs through
  # Pango rather than the kernel glyph table.
  systemd.services."kmsconvt@${kmsconTty}" = {
    enable = true;
    wantedBy = [ "getty.target" ];
  };

  systemd.services."getty@${kmsconTty}".enable = lib.mkForce false;

  console = {
    packages = with pkgs; [ terminus_font ];
    font = "Lat2-Terminus16";
  };
}
