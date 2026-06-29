{
  flake,
  lib,
  pkgs,
  ...
}:
let
  pkgsWithVscodeExtensions = pkgs.extend flake.inputs.nix-vscode-extensions.overlays.default;
  marketplace =
    (pkgsWithVscodeExtensions.nix-vscode-extensions.forVSCodeVersion pkgs.vscode.version)
    .vscode-marketplace-release;
  marketplaceUniversal =
    flake.inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system}.vscode-marketplace-universal;

  sortedAttrs =
    attrs:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = attrs.${name};
      }) (lib.sort (a: b: a < b) (builtins.attrNames attrs))
    );

  commonExtensions =
    with marketplace;
    [
      aaron-bond.better-comments
      adpyke.codesnap
      arrterian.nix-env-selector
      christian-kohler.path-intellisense
      dotjoshjohnson.xml
      eamodio.gitlens
      evgeniypeshkov.syntax-highlighter
      fill-labs.dependi
      github.vscode-github-actions
      janisdd.vscode-edit-csv
      jnoortheen.nix-ide
      kisstkondoros.vscode-gutter-preview
      mechatroner.rainbow-csv
      mhutchie.git-graph
      mkhl.direnv
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.remote-explorer
      myriad-dreamin.tinymist
      nefrob.vscode-just-syntax
      pkief.material-icon-theme
      redhat.vscode-xml
      redhat.vscode-yaml
      robbowen.synthwave-vscode
      shardulm94.trailing-spaces
      streetsidesoftware.code-spell-checker
      tamasfe.even-better-toml
      thenuprojectcontributors.vscode-nushell-lang
      tomoki1207.pdf
      usernamehw.errorlens
      yzhang.markdown-all-in-one
      zh9528.file-size
    ]
    ++ [
      marketplaceUniversal.katsute.code-background
      pkgs.vscode-extensions.ms-ceintl.vscode-language-pack-zh-hans
    ];

  baseCommonUserSettings = {
    "[xml]" = {
      "editor.defaultFormatter" = "redhat.vscode-xml";
    };
    "dev.containers.dockerPath" = if pkgs.stdenv.isDarwin then "docker" else "podman";
    "diffEditor.ignoreTrimWhitespace" = false;
    "editor.foldingImportsByDefault" = true;
    "editor.fontFamily" = "\"Maple Mono NF CN\", \"Noto Color Emoji\"";
    "editor.fontWeight" = "600";
    "editor.formatOnSave" = true;
    "editor.inlayHints.padding" = true;
    "editor.minimap.renderCharacters" = false;
    "editor.minimap.showSlider" = "always";
    "editor.mouseWheelZoom" = true;
    "editor.tabSize" = 2;
    "editor.wordWrap" = "bounded";
    "editor.wordWrapColumn" = 96;
    "extensions.autoCheckUpdates" = false;
    "extensions.autoUpdate" = false;
    "files.autoSave" = "onWindowChange";
    "git.autofetch" = true;
    "http.proxySupport" = "on";
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nixd";
    "nix.serverSettings" = {
      nixd.formatting.command = [ "nixfmt" ];
    };
    "nixEnvSelector.useFlakes" = true;
    "remote.SSH.remotePlatform" = {
      sgx = "linux";
      tdx = "linux";
    };
    "telemetry.feedback.enabled" = false;
    "telemetry.telemetryLevel" = "off";
    "terminal.integrated.customGlyphs" = false;
    "terminal.integrated.suggest.enabled" = true;
    "update.mode" = "none";
    "update.showReleaseNotes" = false;
    "workbench.colorTheme" = "SynthWave '84";
    "workbench.enableExperiments" = false;
    "workbench.iconTheme" = "material-icon-theme";
    "xml.codeLens.enabled" = true;
    "xml.format.maxLineWidth" = 0;
  };

  commonUserSettings = sortedAttrs (
    baseCommonUserSettings
    // {
      "chat.disableAIFeatures" = true;
      "settingsSync.ignoredExtensions" = [
        "github.copilot"
        "github.copilot-chat"
      ];
      "settingsSync.ignoredSettings" = managedSettingKeys;
    }
  );

  cppUserSettings = sortedAttrs {
    "lldb.suppressUpdateNotifications" = true;
  };

  rustUserSettings = sortedAttrs {
    "rust-analyzer.assist.emitMustUse" = true;
    "rust-analyzer.check.command" = "clippy";
    "rust-analyzer.completion.fullFunctionSignatures.enable" = true;
    "rust-analyzer.completion.termSearch.enable" = true;
    "rust-analyzer.diagnostics.styleLints.enable" = true;
    "rust-analyzer.imports.preferNoStd" = true;
    "rust-analyzer.inlayHints.closureCaptureHints.enable" = true;
    "rust-analyzer.inlayHints.closureReturnTypeHints.enable" = "always";
    "rust-analyzer.inlayHints.discriminantHints.enable" = "always";
    "rust-analyzer.inlayHints.expressionAdjustmentHints.enable" = "always";
    "rust-analyzer.inlayHints.genericParameterHints.lifetime.enable" = true;
    "rust-analyzer.inlayHints.genericParameterHints.type.enable" = true;
    "rust-analyzer.inlayHints.implicitDrops.enable" = true;
    "rust-analyzer.inlayHints.implicitSizedBoundHints.enable" = true;
    "rust-analyzer.inlayHints.lifetimeElisionHints.enable" = "skip_trivial";
    "rust-analyzer.inlayHints.rangeExclusiveHints.enable" = true;
    "rust-analyzer.inlayHints.reborrowHints.enable" = "always";
    "rust-analyzer.lens.references.adt.enable" = true;
    "rust-analyzer.lens.references.enumVariant.enable" = true;
    "rust-analyzer.lens.references.method.enable" = true;
    "rust-analyzer.lens.references.trait.enable" = true;
    "rust-analyzer.semanticHighlighting.operator.specialization.enable" = true;
    "rust-analyzer.semanticHighlighting.punctuation.enable" = true;
    "rust-analyzer.semanticHighlighting.punctuation.separate.macro.bang" = true;
    "rust-analyzer.semanticHighlighting.punctuation.specialization.enable" = true;
    "rust-analyzer.showSyntaxTree" = true;
    "rust-analyzer.testExplorer" = true;
    "rust-analyzer.workspace.symbol.search.kind" = "all_symbols";
  };

  texUserSettings = sortedAttrs {
    "latex-workshop.formatting.latex" = "latexindent";
  };

  managedSettingKeys = lib.sort (a: b: a < b) (
    lib.unique (
      builtins.attrNames baseCommonUserSettings
      ++ builtins.attrNames cppUserSettings
      ++ builtins.attrNames rustUserSettings
      ++ builtins.attrNames texUserSettings
      ++ [
        "chat.disableAIFeatures"
        "settingsSync.ignoredExtensions"
        "settingsSync.ignoredSettings"
      ]
    )
  );

  cppExtensions =
    with marketplace;
    [
      jeff-hykin.better-cpp-syntax
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools
    ]
    ++ [
      marketplaceUniversal.vadimcn.vscode-lldb
    ];

  rustExtensions = with marketplace; [
    lorenzopirro.rust-flash-snippets
    rust-lang.rust-analyzer
    sunshaoce.risc-v
  ];

  texExtensions = with marketplace; [
    james-yu.latex-workshop
    ltex-plus.vscode-ltex-plus
  ];
in
{
  home.file.".vscode/argv.json".text =
    builtins.toJSON {
      "enable-crash-reporter" = false;
      locale = "zh-cn";
    }
    + "\n";

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.vscode;

    profiles = {
      "C++" = {
        extensions = commonExtensions ++ cppExtensions;
        userSettings = commonUserSettings // cppUserSettings;
      };

      Rust = {
        extensions = commonExtensions ++ rustExtensions;
        userSettings = commonUserSettings // rustUserSettings;
      };

      TeX = {
        extensions = commonExtensions ++ texExtensions;
        userSettings = commonUserSettings // texUserSettings;
      };

      default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        extensions = commonExtensions;
        userSettings = commonUserSettings;
      };
    };
  };
}
