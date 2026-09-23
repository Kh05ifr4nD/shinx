{
  config,
  flake,
  lib,
  ...
}:

let
  inherit (flake.config) user;
  codexHome = "${config.home-manager.users.${user.name}.home.homeDirectory}/.codex";
  networkProxyEnv = import ../../proxy-env.nix { inherit lib; };
  guiSessionPath = lib.concatStringsSep ":" [
    "/etc/profiles/per-user/${user.name}/bin"
    "/run/current-system/sw/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
in
{
  launchd.user.envVariables = networkProxyEnv // {
    CODEX_HOME = codexHome;
    PATH = guiSessionPath;
  };
  nix.envVars = networkProxyEnv;
}
