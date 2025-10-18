{
  flake,
  lib,
  config,
  ...
}:

let
  inherit (flake.config) user;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    mkMerge
    mkDefault
    ;
  cfg = config.modules.network;
  hasStatic = builtins.length (builtins.attrNames (cfg.interfaces or { })) > 0;
  netIfs = lib.mapAttrs (_name: v: {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = v.address;
        prefixLength = v.prefixLength;
      }
    ];
  }) (cfg.interfaces or { });
  ifaceNames = builtins.attrNames (cfg.interfaces or { });
  firstStaticIf = if (builtins.length ifaceNames) > 0 then builtins.head ifaceNames else null;
  coercedGateway =
    if cfg.defaultGateway == null then
      null
    else if builtins.isString cfg.defaultGateway then
      {
        address = cfg.defaultGateway;
        interface = firstStaticIf;
      }
    else
      cfg.defaultGateway;
in
{
  options.modules.network = {
    backend = mkOption {
      type = types.enum [
        "networkmanager"
        "networkd"
      ];
      default = "networkmanager";
      description = "Networking backend to use. Auto-switches to networkd when static interfaces are defined.";
    };
    interfaces = mkOption {
      type = types.attrsOf (
        types.submodule (
          { ... }:
          {
            options = {
              address = mkOption {
                type = types.str;
                description = "IPv4 address";
              };
              prefixLength = mkOption {
                type = types.int;
                description = "CIDR prefix length";
              };
            };
          }
        )
      );
      default = { };
      description = "Static IPv4 interface definitions. If non-empty, DHCP is disabled and networkd is used.";
    };
    defaultGateway = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default IPv4 gateway when using static addressing.";
    };
    nameservers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "DNS servers when using static addressing.";
    };
  };

  config = mkMerge [
    {
      networking.firewall.enable = true;
    }

    # DHCP via NetworkManager by default when no static interfaces are defined
    (mkIf (!hasStatic && cfg.backend == "networkmanager" && !(config ? wsl && config.wsl.enable)) {
      networking.networkmanager.enable = mkDefault true;
      users.users.${user.name}.extraGroups = lib.mkAfter [ "networkmanager" ];
    })

    # Static IPs via systemd-networkd when interfaces are provided or backend forced
    (mkIf (hasStatic || (cfg.backend == "networkd" && !(config ? wsl && config.wsl.enable))) {
      networking = {
        useNetworkd = true;
        useDHCP = false;
        networkmanager.enable = mkDefault false;
        interfaces = netIfs;
      };
    })

    # Only set gateway/nameservers in static/networkd mode, and only when provided
    (mkIf ((hasStatic || cfg.backend == "networkd") && coercedGateway != null) {
      networking.defaultGateway = coercedGateway;
    })

    (mkIf ((hasStatic || cfg.backend == "networkd") && cfg.nameservers != [ ]) {
      networking.nameservers = cfg.nameservers;
    })
  ];
}
