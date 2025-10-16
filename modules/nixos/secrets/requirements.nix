{
  lib,
  config,
  flake,
  ...
}:
with lib;
let
  inherit (flake) inputs;
  mysecrets = inputs.mysecrets or null;
  hasMysecrets = mysecrets != null;
  cfg = config.modules.secrets;
  hostDirStr =
    if hasMysecrets then
      "${builtins.toString mysecrets}/${config.networking.hostName}"
    else
      "<mysecrets>/<host>";
  # Path-typed host dir to make pathExists reliable
  hostDirPath = if hasMysecrets then mysecrets + "/${config.networking.hostName}" else null;
in
{
  config = mkMerge [
    {
      assertions = [
        {
          assertion = hasMysecrets;
          message = ''必须提供 mysecrets 私有仓库输入（参见 secrets/README.md）'';
        }
        {
          assertion = hasMysecrets && builtins.pathExists (mysecrets + "/secrets.nix");
          message = ''未找到 ${builtins.toString mysecrets}/secrets.nix，请确认私密仓库获取成功且包含规则文件'';
        }
      ];
    }

    (mkIf cfg.user.enable {
      assertions = [
        {
          assertion =
            hasMysecrets && builtins.pathExists (mysecrets + "/${config.networking.hostName}/id.age");
          message = ''未找到 ${hostDirStr}/id.age，请在私密仓库为该主机创建对应文件'';
        }
        {
          assertion =
            hasMysecrets
            && builtins.pathExists (mysecrets + "/${config.networking.hostName}/git/signing.key.conf.age");
          message = ''未找到 ${hostDirStr}/git/signing.key.conf.age（GPG 公钥配置），请在私密仓库提供'';
        }
        {
          assertion =
            hasMysecrets
            && builtins.pathExists (mysecrets + "/${config.networking.hostName}/ssh/config.github.conf.age");
          message = ''未找到 ${hostDirStr}/ssh/config.github.conf.age（SSH 配置），请在私密仓库提供'';
        }
      ];
    })
  ];
}
