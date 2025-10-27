{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (flake.config) user;

  # Reuse the builder packaging from sodiboo/niri-flake; fall back to nixpkgs if unavailable.
  niriPackages = flake.inputs.niri.packages or { };
  niriPkg = lib.attrByPath [ pkgs.stdenv.hostPlatform.system "niri-stable" ] pkgs.niri niriPackages;
in
{
  config = {
    programs.niri = {
      enable = lib.mkDefault true;
      package = lib.mkDefault niriPkg;
    };

    services = {
      xserver.enable = lib.mkDefault false;

      greetd = {
        enable = lib.mkDefault true;
        settings.default_session = {
          command = lib.mkForce "$HOME/.wayland-session";
          user = lib.mkForce user.name;
        };
      };
    };
  };
}
