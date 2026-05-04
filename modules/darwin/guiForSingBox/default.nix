{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (flake.config) user;
  appSupport = "/Users/${user.name}/Library/Application Support/GUI.for.SingBox";
  configDir = "${flake.inputs.self}/configurations/darwin/${config.modules.host.name}/gui-for-singbox";
  installFile = source: target: ''
    install -m 0644 -o ${lib.escapeShellArg user.name} -g staff ${lib.escapeShellArg source} ${lib.escapeShellArg target}
  '';
in
{
  sops.secrets = {
    "gui-for-singbox/subscribes.yaml" = {
      mode = "0400";
      owner = user.name;
      path = "${appSupport}/subscribes.yaml";
    };
    "gui-for-singbox/subscribes/ID_qryqcgz4.json" = {
      mode = "0400";
      owner = user.name;
      path = "${appSupport}/subscribes/ID_qryqcgz4.json";
    };
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "syncing GUI.for.SingBox configuration..."

    install -d -m 0755 -o ${lib.escapeShellArg user.name} -g staff ${lib.escapeShellArg appSupport}
    install -d -m 0755 -o ${lib.escapeShellArg user.name} -g staff ${lib.escapeShellArg "${appSupport}/subscribes"}

    ${installFile "${configDir}/profiles.yaml" "${appSupport}/profiles.yaml"}
    ${installFile "${configDir}/user.yaml" "${appSupport}/user.yaml"}
  '';
}
