{
  arch,
  flake,
  host,
  lib,
  pkgs,
  ...
}:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  environment = {
    sessionVariables = {
      EDITOR = "hx";
    };
    systemPackages = with pkgs; [
      curl
      unzip
      wget
      xz
    ];
  };
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)))
    ++ (with inputs; [
      nix-ld.nixosModules.nix-ld
      self.nixosModules.secrets
    ]);
  networking.hostName = host;
  nixpkgs.hostPlatform = arch;
  programs.nix-ld = {
    dev.enable = true;
    # Minimal set for headless/WSL/server: keep common CLI dependencies only
    libraries = with pkgs; [
      bzip2
      curlWithGnuTls
      e2fsprogs
      expat
      glib
      gmp
      icu
      libcap
      libgcrypt
      libgpg-error
      libidn
      libuuid
      libxml2
      nspr
      nss
      openssl
      p11-kit
      udev
      xz
      zlib
    ];
  };
  services.openssh.enable = lib.mkDefault false;
  modules.secrets.user.enable = lib.mkDefault true;
  system.stateVersion = "24.05";
}
