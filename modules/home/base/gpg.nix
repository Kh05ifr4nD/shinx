{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.gpg = {
    enable = true;
    settings = {
      auto-key-retrieve = true;
      keyid-format = "0xlong";
      keyserver = "hkps://keys.openpgp.org";
      list-options = "show-uid-validity";
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
    };
  };

  services.gpg-agent = {
    defaultCacheTtl = 1800;
    enable = true;
    enableSshSupport = true;
    extraConfig = ''
      allow-loopback-pinentry
    '';
    maxCacheTtl = 7200;
    pinentry.package = lib.mkDefault (
      if (config.services.xserver.enable or false) then pkgs.pinentry-qt else pkgs.pinentry-curses
    );

  };
}
