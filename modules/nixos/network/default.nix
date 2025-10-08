{ config, flake, lib, ... }:

let
  inherit (flake.config) user;
  secretDefaults = lib.attrByPath [ "network" "staticIPv4" ] { } flake.config.secrets;
  cfg = config.shinx.network.staticIPv4;
  inherit (lib) mkAfter mkForce mkIf mkMerge mkOption optionalAttrs types;
in {
  options.shinx.network.staticIPv4 = {
    enable = mkOption {
      type = types.bool;
      default = lib.attrByPath [ "enable" ] false secretDefaults;
      description = "Configure a static IPv4 address instead of relying on DHCP.";
    };

    interface = mkOption {
      type = types.str;
      default = lib.attrByPath [ "interface" ] "" secretDefaults;
      example = "enp3s0";
      description = "Network interface that should use the static IPv4 address.";
    };

    address = mkOption {
      type = types.str;
      default = lib.attrByPath [ "address" ] "" secretDefaults;
      example = "192.168.1.100";
      description = "Static IPv4 address assigned to the interface.";
    };

    prefixLength = mkOption {
      type = types.int;
      default = lib.attrByPath [ "prefixLength" ] 24 secretDefaults;
      example = 24;
      description = "Prefix length (CIDR) for the static IPv4 address.";
    };

    gateway = mkOption {
      type = types.nullOr types.str;
      default = lib.attrByPath [ "gateway" ] null secretDefaults;
      example = "192.168.1.1";
      description = "Optional default gateway for the static IPv4 configuration.";
    };

    dnsServers = mkOption {
      type = types.listOf types.str;
      default = lib.attrByPath [ "dnsServers" ] [ ] secretDefaults;
      example = [ "223.5.5.5" "223.6.6.6" ];
      description = "Optional list of DNS servers to use with the static IPv4 configuration.";
    };
  };

  config = {
    assertions = [
      {
        assertion = !cfg.enable || (cfg.interface != "" && cfg.address != "");
        message = "shinx.network.staticIPv4 requires both an interface and IPv4 address when enabled.";
      }
    ];

    networking = mkMerge [
      {
        firewall.enable = true;
        networkmanager.enable = true;
      }
      (mkIf cfg.enable (
        {
          networkmanager.enable = lib.mkForce false;
          useDHCP = false;
          interfaces = {
            "${cfg.interface}" = {
              useDHCP = false;
              ipv4.addresses = [
                {
                  address = cfg.address;
                  prefixLength = cfg.prefixLength;
                }
              ];
            };
          };
        }
        // optionalAttrs (cfg.gateway != null) {
          defaultGateway = cfg.gateway;
        }
        // optionalAttrs (cfg.dnsServers != [ ]) {
          nameservers = cfg.dnsServers;
        }
      ))
    ];

    users.users.${user.name}.extraGroups = mkAfter [ "networkmanager" ];
  };
}
