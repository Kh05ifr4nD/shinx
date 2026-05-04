{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  gnupgHome = "${config.home.homeDirectory}/.gnupg";
  hasGpgPrivateKey =
    osConfig ? sops
    && osConfig.sops ? secrets
    && builtins.hasAttr "gpg/privateKey.asc" osConfig.sops.secrets;
in
{
  home.activation.importGpgPrivateKey = lib.mkIf hasGpgPrivateKey (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      private_key="${osConfig.sops.secrets."gpg/privateKey.asc".path}"
      if [ -s "$private_key" ]; then
        mkdir -m 700 -p ${lib.escapeShellArg gnupgHome}
        fingerprint="$(${pkgs.gnupg}/bin/gpg --batch --show-keys --with-colons "$private_key" 2>/dev/null | ${pkgs.gawk}/bin/awk -F: '/^fpr:/ { print $10; exit }')"
        if [ -n "$fingerprint" ] && ${pkgs.gnupg}/bin/gpg --batch --homedir ${lib.escapeShellArg gnupgHome} --list-secret-keys "$fingerprint" >/dev/null 2>&1; then
          :
        else
          ${pkgs.gnupg}/bin/gpg --batch --homedir ${lib.escapeShellArg gnupgHome} --import "$private_key" >/dev/null
        fi
      fi
    ''
  );

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
    defaultCacheTtl = 86400;
    enable = true;
    enableNushellIntegration = false;
    enableSshSupport = true;
    extraConfig = ''
      allow-loopback-pinentry
    '';
    maxCacheTtl = 259200;
    pinentry.package = lib.mkDefault (
      if pkgs.stdenv.isDarwin then
        pkgs.pinentry_mac
      else if (config.services.xserver.enable or false) then
        pkgs.pinentry-qt
      else
        pkgs.pinentry-curses
    );
  };

  programs.nushell.extraConfig = lib.mkIf config.programs.nushell.enable ''
    let gpg_tty = (^tty | complete)
    if $gpg_tty.exit_code == 0 {
      $env.GPG_TTY = ($gpg_tty.stdout | str trim)
      ${pkgs.gnupg}/bin/gpg-connect-agent --quiet updatestartuptty /bye | ignore
    }
  '';
}
