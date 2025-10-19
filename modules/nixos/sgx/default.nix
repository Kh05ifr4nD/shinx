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
  # Overlay that injects missing <algorithm> includes into sgx-psw sources
  includeAlgorithmOverlay = (
    final: prev: {
      sgx-psw = prev.sgx-psw.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ];
        postPatch = (old.postPatch or "") + ''
          set -eu
          # Only touch C++ sources/headers; avoid .c
          find . -type f \( -name '*.cc' -o -name '*.cpp' -o -name '*.cxx' -o -name '*.hh' -o -name '*.hpp' -o -name '*.h' \) |
          while IFS= read -r f; do
            if grep -qE '\\bstd::(min|max|sort|upper_bound|lower_bound|remove|unique|max_element|min_element|clamp)\\b' "$f"; then
              if ! grep -qE '^\s*#\s*include\s*<algorithm>' "$f"; then
                sed -i '1i #include <algorithm>' "$f"
              fi
            fi
          done
        '';
      });
    }
  );

  gcc12Overlay = (
    final: prev: {
      sgx-psw = prev.sgx-psw.overrideAttrs (_: {
        stdenv = prev.gcc12Stdenv;
      });
    }
  );
in
{
  options.modules.sgx = {
    psw = {
      fixIncludeAlgorithm = mkOption {
        type = types.bool;
        default = true;
        description = "Hotfix sgx-psw by injecting missing <algorithm> includes in sources.";
      };
      useGcc12 = mkOption {
        type = types.bool;
        default = false;
        description = "Build sgx-psw with gcc12Stdenv to sidestep stricter headers on newer GCC.";
      };
    };

    sdk.enable = mkEnableOption "Install Intel SGX SDK for application development";

    aesmd = {
      quoteProviderLibrary = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Optional DCAP Quote Provider library path (libdcap_quoteprov.so).";
      };
    };
  };

  config = mkMerge [
    # Apply overlays in requested order: include fix first, then gcc12 fallback if asked
    {
      nixpkgs.overlays =
        (lib.optional cfg.psw.fixIncludeAlgorithm includeAlgorithmOverlay)
        ++ (lib.optional cfg.psw.useGcc12 gcc12Overlay);
    }

    # Optionally install SDK for development; PSW is used by AESM via services.aesmd.package
    {
      environment.systemPackages = (lib.optional cfg.sdk.enable pkgs.sgx-sdk);
    }

    # AESM service: always enabled if this module is imported
    {
      services.aesmd = {
        enable = true;
        package = pkgs.sgx-psw;
      }
      // (lib.optionalAttrs (cfg.aesmd.quoteProviderLibrary != null) {
        quoteProviderLibrary = cfg.aesmd.quoteProviderLibrary;
      });
    }
  ];
}
