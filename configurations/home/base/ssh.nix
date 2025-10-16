{
  flake,
  lib,
  config,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "/etc/agenix/ssh.d/*.conf" ];
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
    };
  };

  home.file.".ssh/id" = {
    source = config.lib.file.mkOutOfStoreSymlink "/etc/agenix/id";
    force = true;
  };

  home.activation.ensureSshDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -d -m 700 "$HOME/.ssh"
  '';

  home.activation.ensureSshPub = lib.hm.dag.entryAfter [ "ensureSshDir" ] ''
    if [ -s "/etc/agenix/id" ]; then
      if [ ! -e "$HOME/.ssh/id.pub" ] || ! cmp -s <(/run/current-system/sw/bin/ssh-keygen -y -f "/etc/agenix/id" 2>/dev/null) "$HOME/.ssh/id.pub"; then
        /run/current-system/sw/bin/ssh-keygen -y -f "/etc/agenix/id" > "$HOME/.ssh/id.pub" 2>/dev/null || true
        chmod 644 "$HOME/.ssh/id.pub" || true
      fi
    fi
  '';
}
