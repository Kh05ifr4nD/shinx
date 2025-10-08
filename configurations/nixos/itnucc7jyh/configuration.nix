{ ... }:
{
  # 如需为 itnucc7jyh 配置静态 IPv4，请在上层填充 shinx.network.staticIPv4，
  # 或者通过 sops 加密后的 secrets（SHINX_SECRETS_FILE / flake inputs.secrets /
  # modules/flake/cfg.secrets.yaml）提供 network.staticIPv4.* 字段。
  # 例如：
  # shinx.network.staticIPv4 = {
  #   enable = true;
  #   interface = "enp3s0";
  #   address = "192.168.1.10";
  #   prefixLength = 24;
  #   gateway = "192.168.1.1";
  #   dnsServers = [ "223.5.5.5" "223.6.6.6" ];
  # };
}
