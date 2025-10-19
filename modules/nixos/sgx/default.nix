{
  config,
  lib,
  pkgs,
  flake,
  ...
}:
with lib;
let
  cfg = config.modules.sgx;
  userName = flake.config.user.name;
  pswFixOverlay = (
    final: prev: {
      sgx-psw = prev.sgx-psw.overrideAttrs (old: {
        patches = (old.patches or [ ]);
        postPatch = (old.postPatch or "") + ''
          set -eu
          # 1) Fix missing <algorithm> in C++ code that uses std::sort/upper_bound/remove
          f=psw/enclave_common/sgx_enclave_common.cpp
          if [ -f "$f" ]; then
            if ! grep -qE '^[[:space:]]*#[[:space:]]*include[[:space:]]*<algorithm>' "$f"; then
              sed -i '1i #include <algorithm>' "$f"
            fi
          fi

          # 2) Make vendored CppMicroServices compatible with modern CMake policies
          cmf="external/CppMicroServices/CMakeLists.txt"
          if [ -f "$cmf" ]; then
            # Bump minimum and policy version if present, otherwise insert
            sed -i -E 's/cmake_minimum_required\(VERSION [^)]*\)/cmake_minimum_required(VERSION 3.5)/' "$cmf" || true
            sed -i -E 's/cmake_policy\(VERSION [^)]*\)/cmake_policy(VERSION 3.5)/' "$cmf" || true
            grep -qE '^[[:space:]]*cmake_minimum_required\(VERSION' "$cmf" || sed -i '1i cmake_minimum_required(VERSION 3.5)' "$cmf"
            grep -qE '^[[:space:]]*cmake_policy\(VERSION' "$cmf" || sed -i '2i cmake_policy(VERSION 3.5)' "$cmf"
          fi

          # 3) aesm_service: ensure its own CMakeLists use modern minimum/policy
          if [ -d psw/ae/aesm_service/source ]; then
            while IFS= read -r cmf2; do
              sed -i -E 's/cmake_minimum_required\(VERSION [^)]*\)/cmake_minimum_required(VERSION 3.5)/' "$cmf2" || true
              sed -i -E 's/cmake_policy\(VERSION [^)]*\)/cmake_policy(VERSION 3.5)/' "$cmf2" || true
              grep -qE '^[[:space:]]*cmake_minimum_required\(VERSION' "$cmf2" || sed -i '1i cmake_minimum_required(VERSION 3.5)' "$cmf2"
              # Keep policy just after minimum for predictability
              grep -qE '^[[:space:]]*cmake_policy\(VERSION' "$cmf2" || sed -i '2i cmake_policy(VERSION 3.5)' "$cmf2"
            done < <(find psw/ae/aesm_service/source -name CMakeLists.txt)
          fi

          # Fallback: inject policy minimum into cmake invocations in Makefile
          if [ -f psw/ae/aesm_service/Makefile ]; then
            sed -i -E 's|cmake[[:space:]]+|cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 |g' psw/ae/aesm_service/Makefile || true
          fi
        '';
      });
    }
  );
in
{
  options.modules.sgx.aesmd.quoteProviderLibrary = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = "可选 DCAP Quote Provider（libdcap_quoteprov.so）路径或包。";
  };

  config = {
    nixpkgs.overlays = [ pswFixOverlay ];

    services.aesmd = {
      enable = true;
      package = pkgs.sgx-psw;
    }
    // (optionalAttrs (cfg.aesmd.quoteProviderLibrary != null) {
      quoteProviderLibrary = cfg.aesmd.quoteProviderLibrary;
    });

    systemd.services.aesmd.serviceConfig.PermissionsStartOnly = true;
    users.users.${userName}.extraGroups = lib.mkAfter [ "sgx" ];
  };
}
