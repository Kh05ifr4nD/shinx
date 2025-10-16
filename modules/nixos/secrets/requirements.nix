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
  host = config.networking.hostName;
  specs = import ./specs.nix { userName = (flake.config.user.name); };
  names = builtins.attrNames specs;
  hostDirStr =
    if hasMysecrets then "${builtins.toString mysecrets}/${host}" else "<mysecrets>/<host>";
  hostDirPath = if hasMysecrets then mysecrets + "/${host}" else null;
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
        {
          assertion = hasMysecrets && builtins.pathExists hostDirPath;
          message = ''未找到 ${hostDirStr} 目录，请确认为该主机准备了密文目录'';
        }
      ];
    }

    (mkIf cfg.user.enable {
      assertions = map (
        name:
        let
          relPath = specs.${name}.relPath;
        in
        {
          assertion = hasMysecrets && builtins.pathExists (hostDirPath + relPath);
          message = ''未找到 ${hostDirStr}${relPath}（密文：${name}），请在私密仓库提供对应密文文件'';
        }
      ) names;
    })
  ];
}
