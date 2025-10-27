{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  niriFlake = flake.inputs.niri;
  inherit (niriFlake.lib.kdl) plain leaf flag;

  systemKey = pkgs.stdenv.hostPlatform.system;
  niriPackages = niriFlake.packages or { };
  niriPkg = lib.attrByPath [ systemKey "niri-stable" ] pkgs.niri niriPackages;
  xwaylandSatellitePkg = lib.attrByPath [
    systemKey
    "xwayland-satellite-stable"
  ] pkgs.xwayland-satellite niriPackages;

  cfg = config.programs.niri;

  niriConfig = [
    (plain "input" [
      (plain "keyboard" [
        (plain "xkb" [ ])
      ])
      (plain "touchpad" [
        (flag "tap")
        (flag "natural-scroll")
        (flag "dwt")
      ])
    ])
    (plain "layout" [
      (leaf "gaps" 12)
      (plain "focus-ring" [
        (leaf "width" 4)
        (leaf "active-color" "#7fc8ff")
        (leaf "inactive-color" "#505050")
      ])
      (plain "preset-column-widths" [
        (leaf "proportion" (1.0 / 3.0))
        (leaf "proportion" 0.5)
        (leaf "proportion" (2.0 / 3.0))
      ])
      (plain "default-column-width" [
        (leaf "proportion" 0.5)
      ])
      (plain "layer-rule" [
        (leaf "match" { namespace = "waybar"; })
        (leaf "opacity" 0.9)
      ])
    ])
    (leaf "screenshot-path" "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png")
    (leaf "spawn-at-startup" [ "waybar" ])
    (leaf "spawn-sh-at-startup" "systemctl --user reset-failed waybar.service || true")
    (plain "environment" [
      (leaf "NIXOS_OZONE_WL" "1")
    ])
    (plain "binds" [
      (plain "Mod+Shift+Slash" [ (flag "show-hotkey-overlay") ])
      (plain "Mod+Return" [ (leaf "spawn" [ "foot" ]) ])
      (plain "Mod+D" [ (leaf "spawn" [ "fuzzel" ]) ])
      (plain "Super+Alt+L" [ (leaf "spawn" [ "swaylock" ]) ])
      (plain "Mod+Shift+E" [ (leaf "spawn" [ "wlogout" ]) ])

      (plain "XF86AudioRaiseVolume" [
        (leaf "spawn" [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "0.05+"
        ])
      ])
      (plain "XF86AudioLowerVolume" [
        (leaf "spawn" [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "0.05-"
        ])
      ])
      (plain "XF86AudioMute" [
        (leaf "spawn" [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SINK@"
          "toggle"
        ])
      ])

      (plain "Mod+Q" [ (flag "close-window") ])

      (plain "Mod+Left" [ (flag "focus-column-left") ])
      (plain "Mod+Down" [ (flag "focus-window-down") ])
      (plain "Mod+Up" [ (flag "focus-window-up") ])
      (plain "Mod+Right" [ (flag "focus-column-right") ])
      (plain "Mod+H" [ (flag "focus-column-left") ])
      (plain "Mod+J" [ (flag "focus-window-down") ])
      (plain "Mod+K" [ (flag "focus-window-up") ])
      (plain "Mod+L" [ (flag "focus-column-right") ])

      (plain "Mod+Ctrl+Left" [ (flag "move-column-left") ])
      (plain "Mod+Ctrl+Down" [ (flag "move-window-down") ])
      (plain "Mod+Ctrl+Up" [ (flag "move-window-up") ])
      (plain "Mod+Ctrl+Right" [ (flag "move-column-right") ])

      (plain "Mod+Shift+Left" [ (flag "focus-monitor-left") ])
      (plain "Mod+Shift+Down" [ (flag "focus-monitor-down") ])
      (plain "Mod+Shift+Up" [ (flag "focus-monitor-up") ])
      (plain "Mod+Shift+Right" [ (flag "focus-monitor-right") ])

      (plain "Mod+Page_Down" [ (flag "focus-workspace-down") ])
      (plain "Mod+Page_Up" [ (flag "focus-workspace-up") ])
      (plain "Mod+Ctrl+Page_Down" [ (flag "move-column-to-workspace-down") ])
      (plain "Mod+Ctrl+Page_Up" [ (flag "move-column-to-workspace-up") ])

      (plain "Mod+1" [ (leaf "focus-workspace" "1-terminal") ])
      (plain "Mod+2" [ (leaf "focus-workspace" "2-browser") ])
      (plain "Mod+3" [ (leaf "focus-workspace" "3-chat") ])
      (plain "Mod+4" [ (leaf "focus-workspace" "4-media") ])
      (plain "Mod+5" [ (leaf "focus-workspace" "5-misc") ])
      (plain "Mod+Ctrl+1" [ (leaf "move-column-to-workspace" "1-terminal") ])
      (plain "Mod+Ctrl+2" [ (leaf "move-column-to-workspace" "2-browser") ])
      (plain "Mod+Ctrl+3" [ (leaf "move-column-to-workspace" "3-chat") ])
      (plain "Mod+Ctrl+4" [ (leaf "move-column-to-workspace" "4-media") ])
      (plain "Mod+Ctrl+5" [ (leaf "move-column-to-workspace" "5-misc") ])

      (plain "Print" [
        (leaf "spawn-sh" "grim -g \"$(slurp)\" \"$HOME/Pictures/Screenshots/Screenshot $(date +%Y-%m-%d_%H-%M-%S).png\"")
      ])
    ])
    (plain "window-rule" [
      (leaf "match" { app-id = "foot"; })
      (leaf "open-on-workspace" "1-terminal")
    ])
    (plain "window-rule" [
      (leaf "match" { app-id = "firefox"; })
      (leaf "open-on-workspace" "2-browser")
      (leaf "open-maximized" true)
    ])
    (plain "window-rule" [
      (leaf "match" { app-id = "org.telegram.desktop"; })
      (leaf "open-on-workspace" "3-chat")
    ])
  ];

  waybarConfig = lib.generators.toJSON { } {
    layer = "top";
    position = "top";
    modules-left = [
      "niri/workspaces"
      "niri/mode"
    ];
    modules-center = [ "clock" ];
    modules-right = [
      "network"
      "cpu"
      "memory"
      "pulseaudio"
      "battery"
      "tray"
    ];
    "clock" = {
      format = "{:%Y-%m-%d %H:%M}";
    };
    "network" = {
      format-wifi = "  {signalStrength}%";
      format-ethernet = "󰈁 {ipaddr}";
      format-disconnected = "󱛅";
      tooltip-format = "{ifname}\n{ipaddr}/{cidr}";
    };
    "cpu".format = " {usage}%";
    "memory".format = " {percentage}%";
    "pulseaudio" = {
      format = "{icon} {volume}%";
      format-muted = "󰝟";
      icons = {
        default = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
      };
    };
    "battery" = {
      format = "{icon} {capacity}%";
      format-charging = " {capacity}%";
      format-icons = [
        "󰁺"
        "󰁼"
        "󰁾"
        "󰂂"
        "󰁹"
      ];
    };
  };
in
{
  options.programs.niri.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable the Niri compositor session for the primary user.";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        grim
        slurp
        wl-clipboard
        swaybg
        xwaylandSatellitePkg
      ];
      sessionVariables = {
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_TYPE = "wayland";
        NIXOS_OZONE_WL = "1";
      };
      activation.ensureScreenshotDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/Pictures/Screenshots"
      '';
    };

    programs = {
      foot.enable = true;
      fuzzel.enable = true;
      niri = {
        package = lib.mkDefault niriPkg;
        config = niriConfig;
      };
      swaylock.enable = true;
      waybar = {
        enable = true;
        systemd.enable = true;
      };
      wlogout.enable = true;
    };

    services.mako = {
      enable = true;
      extraConfig = ''
        sort=descending
        layer=overlay
        font=Sans 12
        margin=8
        padding=12
        width=360
        border-size=2
        border-radius=10
        background-color=#1e1e2e
        border-color=#89b4fa
        text-color=#cdd6f4
        progress-color=over #fab387
      '';
    };

    home.file.".wayland-session" = {
      source = pkgs.writeShellScript "niri-wayland-session" ''
        #!/bin/sh
        set -eu
        if systemctl --user is-active --quiet niri.service; then
          systemctl --user stop niri.service
        fi
        exec ${lib.getExe' niriPkg "niri-session"}
      '';
      executable = true;
    };

    xdg.configFile."waybar/config.jsonc".text = waybarConfig;
    xdg.configFile."waybar/style.css".text = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
        border-bottom: 1px solid rgba(137, 180, 250, 0.6);
      }

      #workspaces button {
        padding: 0 6px;
        color: #a6adc8;
      }

      #workspaces button.focused {
        color: #cdd6f4;
        background: rgba(137, 180, 250, 0.3);
      }

      #workspaces button.urgent {
        color: #f38ba8;
        background: rgba(243, 139, 168, 0.3);
      }

      #clock,
      #network,
      #cpu,
      #memory,
      #pulseaudio,
      #battery {
        padding: 0 10px;
      }
    '';
  };
}
