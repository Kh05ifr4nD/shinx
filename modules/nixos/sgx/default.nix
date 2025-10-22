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
  pswFixOverlay = (
    final: prev: {
      sgx-psw = prev.sgx-psw.overrideAttrs (old: {
        patches = (old.patches or [ ]);
        postPatch = (old.postPatch or "") + ''
          set -eu
          f=psw/enclave_common/sgx_enclave_common.cpp
          if [ -f "$f" ]; then
            if ! grep -qE '^[[:space:]]*#[[:space:]]*include[[:space:]]*<algorithm>' "$f"; then
              sed -i '1i #include <algorithm>' "$f"
            fi
          fi
        '';
        dontPatchShebangs = true;
      });
    }
  );
  pkgs2411 = import inputs.nixpkgs-24_11 {
    inherit (pkgs) system;
    overlays = [ pswFixOverlay ];
  };
in
{
  options.modules.sgx.aesmd.quoteProviderLibrary = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = "可选 DCAP Quote Provider（libdcap_quoteprov.so）路径或包。";
  };

  config = {
    boot.kernelPackages = lib.mkForce (
      pkgs.linuxPackagesFor (
        pkgs.linux.override {
          structuredExtraConfig = with pkgs.lib.kernel; [
            (mkForce "X86_SGX_KVM" "y")
            (mkForce "X86_SGX" "y")
            (mkForce "X86_SGX2" "y")
          ];
        }
      )
    );
    hardware.cpu.intel.sgx.provision.enable = true;
    nixpkgs.overlays = [ pswFixOverlay ];
    services.aesmd = {
      enable = true;
      package = pkgs2411.sgx-psw;
    }
    // (optionalAttrs (cfg.aesmd.quoteProviderLibrary != null) {
      quoteProviderLibrary = cfg.aesmd.quoteProviderLibrary;
    });
    systemd.services.aesmd.serviceConfig.PermissionsStartOnly = true;
    users.users.${userName}.extraGroups = lib.mkAfter [ "sgx" ];
  };
}
