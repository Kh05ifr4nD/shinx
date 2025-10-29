{
  config,
  lib,
  flake,
  pkgs,
  ...
}:
with lib;
let
  inherit (flake) inputs;
  cfg = config.modules.sgx;
  userName = flake.config.user.name;
  sgxPswLocal = pkgs.callPackage ./psw { };
in
{
  options.modules.sgx.aesmd.quoteProviderLibrary = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = "可选 DCAP Quote Provider（libdcap_quoteprov.so）路径或包。";
  };

  config = {
    hardware.cpu.intel.sgx.provision.enable = true;
    services.aesmd = {
      enable = true;
      package = sgxPswLocal;
    }
    // (optionalAttrs (cfg.aesmd.quoteProviderLibrary != null) {
      quoteProviderLibrary = cfg.aesmd.quoteProviderLibrary;
    });
    systemd.services.aesmd.serviceConfig.PermissionsStartOnly = true;
    users.users.${userName}.extraGroups = lib.mkAfter [ "sgx" ];
  };
}
