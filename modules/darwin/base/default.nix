{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake.config) user;
  keyboardBacklight = {
    autoBrightness = true;
    brightness = null;
    idleDimTime = 300;
    idleDimming = true;
  };
  macBrightnessctl = pkgs.callPackage (flake.inputs.self + /packages/mac-brightnessctl) { };
  nuLoginShell = "/run/current-system/sw/bin/nu";
  runAsUser = command: ''
    launchctl asuser "$(id -u -- ${lib.escapeShellArg user.name})" sudo --user=${lib.escapeShellArg user.name} -- ${command}
  '';
  toCliBool = value: if value then "1" else "0";
in
{
  imports = with builtins; map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)));

  environment = {
    shells = with pkgs; [ nushell ];
    systemPackages = with pkgs; [
      age
      bat
      curl
      eza
      fd
      git
      jq
      macBrightnessctl
      nh
      nix-output-monitor
      nvd
      sops
      tree
      unzip
      wget
      xz
    ];
    variables.EDITOR = "hx";
  };

  home-manager = {
    backupFileExtension = "backup";
    users.${user.name} = {
      home.stateVersion = config.modules.home.stateVersion;
      imports = [
        (flake.inputs.self + /configurations/home/base)
      ]
      ++ config.modules.home.imports;
    };
  };

  launchd.user.agents.mos = {
    serviceConfig = {
      LimitLoadToSessionType = "Aqua";
      KeepAlive = true;
      ProgramArguments = [
        "/Applications/Mos.app/Contents/MacOS/Mos"
      ];
      RunAtLoad = true;
      StandardErrorPath = "/tmp/org.nixos.mos.stderr.log";
      StandardOutPath = "/tmp/org.nixos.mos.stdout.log";
    };
  };

  networking.hostName = config.modules.host.name;

  nix.settings = {
    accept-flake-config = true;
    allowed-users = [ user.name ];
    extra-substituters = [
      "https://cache.numtide.com"
      "https://cache.thalheim.io"
      "https://nix-community.cachix.org"
      "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store"
    ];
    extra-trusted-public-keys = [
      "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    trusted-users = [
      user.name
    ];
    warn-dirty = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = config.modules.host.arch;
  };

  programs.zsh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    activationScripts.postActivation.text = ''
      echo >&2 "setting keyboard backlight..."
      ${runAsUser "${macBrightnessctl}/bin/mac-brightnessctl -a ${toCliBool keyboardBacklight.autoBrightness}"}
      ${runAsUser "${macBrightnessctl}/bin/mac-brightnessctl -s ${
        toCliBool (!keyboardBacklight.idleDimming)
      }"}
      ${runAsUser "${macBrightnessctl}/bin/mac-brightnessctl -t ${toString keyboardBacklight.idleDimTime}"}
      ${lib.optionalString (keyboardBacklight.brightness != null) (
        runAsUser "${macBrightnessctl}/bin/mac-brightnessctl ${toString keyboardBacklight.brightness}"
      )}

      echo >&2 "setting login shell..."
      if [ "$(dscl . -read ${lib.escapeShellArg "/Users/${user.name}"} UserShell 2>/dev/null | awk '{ print $2 }')" != ${lib.escapeShellArg nuLoginShell} ]; then
        dscl . -create ${lib.escapeShellArg "/Users/${user.name}"} UserShell ${lib.escapeShellArg nuLoginShell}
      fi

    '';

    defaults = {
      CustomUserPreferences = {
        "com.apple.AppleMultitouchTrackpad" = {
          TrackpadHorizScroll = true;
          TrackpadScroll = true;
        };
        "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
          TrackpadHorizScroll = true;
          TrackpadScroll = true;
        };
        "com.apple.HIToolbox" = {
          AppleDictationAutoEnable = true;
          AppleEnabledInputSources = [
            {
              InputSourceKind = "Keyboard Layout";
              "KeyboardLayout ID" = 252;
              "KeyboardLayout Name" = "ABC";
            }
            {
              "Bundle ID" = "com.apple.inputmethod.SCIM";
              InputSourceKind = "Keyboard Input Method";
            }
            {
              "Bundle ID" = "com.apple.inputmethod.SCIM";
              "Input Mode" = "com.apple.inputmethod.SCIM.Shuangpin";
              InputSourceKind = "Input Mode";
            }
          ];
          AppleInputSourceHistory = [
            {
              "Bundle ID" = "com.apple.inputmethod.SCIM";
              "Input Mode" = "com.apple.inputmethod.SCIM.Shuangpin";
              InputSourceKind = "Input Mode";
            }
            {
              InputSourceKind = "Keyboard Layout";
              "KeyboardLayout ID" = 252;
              "KeyboardLayout Name" = "ABC";
            }
          ];
          AppleSelectedInputSources = [
            {
              "Bundle ID" = "com.apple.inputmethod.SCIM";
              "Input Mode" = "com.apple.inputmethod.SCIM.Shuangpin";
              InputSourceKind = "Input Mode";
            }
          ];
        };
        "com.apple.inputmethod.CoreChineseEngineFramework" = {
          fuzzyPinyinEnabled = false;
          shuangpinLayout = 4;
        };
        "com.apple.speech.recognition.AppleSpeechRecognition.prefs" = {
          DictationIMDidAskToConfirmLanguageChoice = true;
          DictationIMIntroMessagePresented = true;
          DictationIMNetworkBasedLocaleIdentifier = "zh_CN";
          DictationIMPreferredLanguageIdentifiers = [
            "zh_CN"
          ];
          DictationIMUseOnlyOfflineDictation = false;
          VisibleNetworkSRLocaleIdentifiers = {
            en_US = false;
            wuu_CN = false;
            yue_CN = false;
            zh_CN = true;
            zh_HK = false;
          };
        };
        "com.caldis.Mos" = {
          deadZone = 1.0;
          duration = 4.35;
          optionsExist = "optionsExist";
          reverse = true;
          reverseHorizontal = false;
          reverseVertical = true;
          smooth = true;
          smoothHorizontal = true;
          smoothSimTrackpad = false;
          smoothVertical = true;
          speed = 2.0;
          step = 30.0;
        };
        "io.tailscale.ipn.macsys" = {
          TailscaleStartOnLogin = true;
        };
      };
      NSGlobalDomain = {
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.swipescrolldirection" = true;
        "com.apple.trackpad.enableSecondaryClick" = true;
        "com.apple.trackpad.forceClick" = true;
        "com.apple.trackpad.scaling" = 2.5;
        AppleEnableMouseSwipeNavigateWithScrolls = true;
        AppleEnableSwipeNavigateWithScrolls = true;
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 30;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSScrollAnimationEnabled = true;
      };
      dock = {
        appswitcher-all-displays = true;
        autohide = true;
        autohide-delay = 0.12;
        autohide-time-modifier = 0.8;
        enable-spring-load-actions-on-all-items = true;
        expose-animation-duration = 0.5;
        expose-group-apps = true;
        largesize = 72;
        launchanim = true;
        magnification = true;
        mineffect = "genie";
        minimize-to-application = false;
        mouse-over-hilite-stack = true;
        mru-spaces = false;
        orientation = "bottom";
        persistent-apps = [
          { app = "/System/Applications/Apps.app"; }
          { app = "/System/Applications/Calendar.app"; }
          { app = "/Applications/Safari.app"; }
          { app = "/Applications/Codex.app"; }
          { app = "/Applications/Visual Studio Code.app"; }
          { app = "/Applications/Ghostty.app"; }
          { app = "/System/Applications/System Settings.app"; }
        ];
        persistent-others = [
          {
            folder = {
              arrangement = "date-added";
              displayas = "folder";
              path = "/Users/${user.name}/Downloads";
              showas = "grid";
            };
          }
        ];
        scroll-to-open = true;
        showAppExposeGestureEnabled = true;
        showDesktopGestureEnabled = true;
        showMissionControlGestureEnabled = true;
        show-process-indicators = true;
        show-recents = true;
        showhidden = true;
        slow-motion-allowed = false;
        static-only = false;
        tilesize = 56;
        wvous-bl-corner = 2;
        wvous-br-corner = 4;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      hitoolbox = {
        AppleFnUsageType = "Show Emoji & Symbols";
      };
      trackpad = {
        ActuationStrength = 0;
        Clicking = true;
        DragLock = false;
        Dragging = true;
        FirstClickThreshold = 1;
        ForceSuppressed = false;
        SecondClickThreshold = 2;
        TrackpadCornerSecondaryClick = 0;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadMomentumScroll = true;
        TrackpadPinch = true;
        TrackpadRightClick = true;
        TrackpadRotate = true;
        TrackpadThreeFingerDrag = true;
        TrackpadThreeFingerHorizSwipeGesture = 0;
        TrackpadThreeFingerTapGesture = 0;
        TrackpadThreeFingerVertSwipeGesture = 0;
        TrackpadTwoFingerDoubleTapGesture = true;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      };
    };
    primaryUser = user.name;
    stateVersion = 6;
  };

  users.users.${user.name} = {
    home = "/Users/${user.name}";
    shell = pkgs.nushell;
  };
}
