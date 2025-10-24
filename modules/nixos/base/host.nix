{ lib, config, ... }:
with lib;
{
  options.modules.host = {
    name = mkOption {
      type = types.str;
      description = "Hostname for this machine (used to set networking.hostName)";
    };
    arch = mkOption {
      type = types.enum [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      description = "Host platform for nixpkgs.hostPlatform";
    };
  };

  config.assertions = [
    {
      assertion = config ? modules && config.modules ? host && config.modules.host ? name;
      message = "modules.host.name is required (per-host).";
    }
    {
      assertion = config ? modules && config.modules ? host && config.modules.host ? arch;
      message = "modules.host.arch is required (per-host).";
    }
  ];
}
