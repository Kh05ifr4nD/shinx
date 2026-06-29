{
  config,
  flake,
  lib,
  ...
}:
let
  inherit (flake.config) user;
  appSupport = "/Users/${user.name}/Library/Application Support/GUI.for.SingBox";
  appBundleData = "/Applications/GUI.for.SingBox.app/Contents/MacOS/data";
  appBundleMacOS = "/Applications/GUI.for.SingBox.app/Contents/MacOS";
  configDir = "${flake.inputs.self}/configurations/darwin/${config.modules.host.name}/gui-for-singbox";
  linkFile = source: target: ''
    if [ -e ${lib.escapeShellArg target} ] || [ -L ${lib.escapeShellArg target} ]; then
      rm ${lib.escapeShellArg target}
    fi
    ln -s ${lib.escapeShellArg source} ${lib.escapeShellArg target}
  '';
  secretFile = name: {
    mode = "0400";
    owner = user.name;
  };
  renderedFile = path: name: {
    mode = "0644";
    owner = user.name;
    inherit path;
    content = config.sops.placeholder.${name};
  };
in
{
  sops.secrets = {
    "gui-for-singbox/clash-api-secret" = secretFile "gui-for-singbox/clash-api-secret";
    "gui-for-singbox/subscribes.yaml" = secretFile "gui-for-singbox/subscribes.yaml";
    "gui-for-singbox/subscribes/ID_aew67zoo.json" =
      secretFile "gui-for-singbox/subscribes/ID_aew67zoo.json";
    "gui-for-singbox/subscribes/ID_d52yd71h.json" =
      secretFile "gui-for-singbox/subscribes/ID_d52yd71h.json";
    "gui-for-singbox/sing-box/config.json" = secretFile "gui-for-singbox/sing-box/config.json";
  };

  sops.templates = {
    "gui-for-singbox/profiles.yaml" = {
      mode = "0644";
      owner = user.name;
      path = "${appSupport}/profiles.yaml";
      content =
        builtins.replaceStrings
          [ ''secret: ""'' ]
          [ ''secret: "${config.sops.placeholder."gui-for-singbox/clash-api-secret"}"'' ]
          (builtins.readFile "${configDir}/profiles.yaml");
    };
    "gui-for-singbox/subscribes.yaml" =
      renderedFile "${appSupport}/subscribes.yaml" "gui-for-singbox/subscribes.yaml";
    "gui-for-singbox/subscribes/ID_aew67zoo.json" =
      renderedFile "${appSupport}/subscribes/ID_aew67zoo.json" "gui-for-singbox/subscribes/ID_aew67zoo.json";
    "gui-for-singbox/subscribes/ID_d52yd71h.json" =
      renderedFile "${appSupport}/subscribes/ID_d52yd71h.json" "gui-for-singbox/subscribes/ID_d52yd71h.json";
    "gui-for-singbox/sing-box/config.json" =
      renderedFile "${appSupport}/sing-box/config.json" "gui-for-singbox/sing-box/config.json";
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "syncing GUI.for.SingBox configuration..."

    install -d -m 0755 -o ${lib.escapeShellArg user.name} -g staff ${lib.escapeShellArg appSupport}
    install -d -m 0755 -o ${lib.escapeShellArg user.name} -g staff ${lib.escapeShellArg "${appSupport}/subscribes"}
    install -d -m 0755 -o ${lib.escapeShellArg user.name} -g staff ${lib.escapeShellArg "${appSupport}/sing-box"}

    if [ -d ${lib.escapeShellArg appBundleMacOS} ]; then
      if [ -e ${lib.escapeShellArg appBundleData} ] && [ ! -L ${lib.escapeShellArg appBundleData} ]; then
        backup="${appBundleData}.bak.$(date +%Y%m%d%H%M%S)"
        mv ${lib.escapeShellArg appBundleData} "$backup"
        echo >&2 "moved existing GUI.for.SingBox app data to $backup"
      fi

      if [ -L ${lib.escapeShellArg appBundleData} ]; then
        current="$(readlink ${lib.escapeShellArg appBundleData})"
        if [ "$current" != ${lib.escapeShellArg appSupport} ]; then
          rm ${lib.escapeShellArg appBundleData}
          ln -s ${lib.escapeShellArg appSupport} ${lib.escapeShellArg appBundleData}
        fi
      elif [ ! -e ${lib.escapeShellArg appBundleData} ]; then
        ln -s ${lib.escapeShellArg appSupport} ${lib.escapeShellArg appBundleData}
      fi
    fi

    ${linkFile "${configDir}/user.yaml" "${appSupport}/user.yaml"}
  '';
}
