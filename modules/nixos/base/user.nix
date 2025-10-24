{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (flake.config) user;

in
{
  home-manager = {
    useGlobalPkgs = true;
    # 自动备份被覆盖的现有文件，避免激活失败（例如 ~/.ssh/config）
    backupFileExtension = "backup";
    users.${user.name} = {
      imports = [
        (flake.inputs.self + /configurations/home/base)
      ]
      ++ (config.modules.home.imports or [ ]);
      home.stateVersion = config.modules.home.stateVersion or "25.05";
    };
    # 将系统侧关于 secrets 的可用性传给 Home Manager，便于做降级处理
    extraSpecialArgs = {
      hasGitSigning = config.age.secrets ? "git-signing.key.conf";
      hasSshGithubConf = config.age.secrets ? "ssh-config.github.conf";
    };
    useUserPackages = true;
  };
  nix.settings = {
    allowed-users = [ user.name ];
    trusted-users = [
      user.name
      "root"
    ];
  };
  users.users.${user.name} = {
    extraGroups = lib.mkBefore [ "wheel" ];
    isNormalUser = true;
    shell = pkgs.nushell;
  };
}
