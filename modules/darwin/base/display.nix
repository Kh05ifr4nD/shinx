{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.modules.host) name;
  primaryUser = config.system.primaryUser or "meandssh";

  displayPreferences = {
    automaticBrightness = true;
    trueTone = true;
  };

  applyDisplayPreferences = pkgs.writeShellScript "apply-display-preferences" ''
    set -u

    plist="/private/var/root/Library/Preferences/com.apple.CoreBrightness.plist"
    pb="/usr/libexec/PlistBuddy"
    user=${lib.escapeShellArg primaryUser}

    uuid="$(/usr/bin/dscl . -read "/Users/$user" GeneratedUID 2>/dev/null \
      | /usr/bin/awk -F': ' '/GeneratedUID/ { print $2 }')"
    [ -n "$uuid" ] || {
      echo >&2 "warning: cannot resolve GeneratedUID for $user; skipping display preferences"
      exit 0
    }

    set_or_add() {
      path="$1"
      type="$2"
      value="$3"

      if "$pb" -c "Print $path" "$plist" >/dev/null 2>&1; then
        "$pb" -c "Set $path $value" "$plist" >/dev/null 2>&1 || true
      else
        "$pb" -c "Add $path $type $value" "$plist" >/dev/null 2>&1 || true
      fi
    }

    if ! "$pb" -c "Print :CBUser-$uuid" "$plist" >/dev/null 2>&1; then
      "$pb" -c "Add :CBUser-$uuid dict" "$plist" >/dev/null 2>&1 || true
    fi

    set_or_add \
      ":CBUser-$uuid:CBColorAdaptationEnabled" \
      integer \
      ${if displayPreferences.trueTone then "1" else "0"}

    display_ids="$("$pb" -c "Print :DisplayPreferences" "$plist" 2>/dev/null \
      | /usr/bin/awk '/= Dict/ {
          gsub(/^[ \t]+|[ \t]+$/, "", $1);
          if ($1 != "AutoBrightnessCurve") print $1
        }')"

    for display_id in $display_ids; do
      set_or_add \
        ":DisplayPreferences:$display_id:AutoBrightnessEnable" \
        bool \
        ${if displayPreferences.automaticBrightness then "true" else "false"}
    done

    if [ -z "$display_ids" ]; then
      echo >&2 "warning: no CoreBrightness DisplayPreferences entries found for auto brightness"
    fi
  '';
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo >&2 "configuring display preferences for ${name}..."
    ${applyDisplayPreferences}
  '';
}
