{ config, lib, ... }:
{
  options.modules.host = {
    arch = lib.mkOption {
      description = "Host platform for nixpkgs.hostPlatform";
      type = lib.types.enum [
        "aarch64-darwin"
      ];
    };
    name = lib.mkOption {
      description = "Hostname for this machine";
      type = lib.types.str;
    };
  };

  config.assertions = [
    {
      assertion = config ? modules && config.modules ? host && config.modules.host ? arch;
      message = "modules.host.arch is required for each Darwin host.";
    }
    {
      assertion = config ? modules && config.modules ? host && config.modules.host ? name;
      message = "modules.host.name is required for each Darwin host.";
    }
  ];
}
