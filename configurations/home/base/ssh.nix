{
  flake,
  lib,
  config,
  hasSshGithubConf ? false,
  ...
}:
let
  inherit (flake.config) user;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # 顶层 Include 由 Home Manager 生成，不再写入 extraConfig
    includes = [ "/etc/agenix/ssh.d/*.conf" ];
    # HM 对某些版本的断言较严格，保留一个最小的默认块
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
    };
    # 当未提供私密 github 配置片段时，提供一个安全的回退配置
    matchBlocks."github.com" = lib.mkIf (!hasSshGithubConf) {
      hostname = "github.com";
      user = "git";
      identitiesOnly = true;
      identityFile = [ "~/.ssh/id" ];
    };
  };

  # 单一密钥对：~/.ssh/id 与 ~/.ssh/id.pub
  # 私钥用 symlink 指向系统落地的 /etc/agenix/id
  home.file.".ssh/id" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/agenix/id";
    force = true;
  };

  # 不再创建额外别名文件，避免多余 id_ed25519/id_rsa 链接

  # Ensure ~/.ssh exists with correct permissions
  home.activation.ensureSshDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -d -m 700 "$HOME/.ssh"
  '';

  # 自动生成公钥：~/.ssh/id.pub（仅当 /etc/agenix/id 可用时从其派生）
  home.activation.ensureSshPub = lib.hm.dag.entryAfter [ "ensureSshDir" ] ''
    if [ -s "/etc/agenix/id" ]; then
      if [ ! -e "$HOME/.ssh/id.pub" ] || ! cmp -s <(/run/current-system/sw/bin/ssh-keygen -y -f "/etc/agenix/id" 2>/dev/null) "$HOME/.ssh/id.pub"; then
        /run/current-system/sw/bin/ssh-keygen -y -f "/etc/agenix/id" > "$HOME/.ssh/id.pub" 2>/dev/null || true
        chmod 644 "$HOME/.ssh/id.pub" || true
      fi
    fi
  '';
}
