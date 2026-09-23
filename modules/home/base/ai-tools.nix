{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  coolheaded = flake.inputs.coolheaded;
  packages = coolheaded.packages or { };
  packageNames = [
    "codeGraph"
    "cursorCli"
    "entire"
    "ohMyPi"
    "qmd"
    "rtk"
    "semble"
    "zvecGrep"
  ];
  systemKey = pkgs.stdenv.hostPlatform.system;
  systemPackages = packages.${systemKey};
  agentPackages = map (name: systemPackages.${name}) packageNames;
  nixpkgsAgentPackages = [
    pkgs.fff-mcp
    pkgs.skills
  ];

  localInferencePackages = [
    pkgs.llama-cpp
  ]
  ++ lib.optionals (pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64) [
    pkgs.python3Packages.mlx-lm
  ];
in
{
  imports = [ coolheaded.homeModules.lazyCodexAi ];

  home.packages = agentPackages ++ nixpkgsAgentPackages ++ localInferencePackages;

  programs = {
    codex = {
      settings = {
        analytics.enabled = false;
        approval_policy = "never";
        approvals_reviewer = "auto_review";
        check_for_update_on_startup = false;
        features = {
          apply_patch_streaming_events = true;
          current_time_reminder = true;
          memories = true;
          multi_agent_v2.max_concurrent_threads_per_session = 512;
          prevent_idle_sleep = true;
          respect_system_proxy = true;
          runtime_metrics = true;
          terminal_visualization_instructions = true;
        };
        feedback.enabled = false;
        file_opener = "vscode";
        history.persistence = "save-all";
        mcp_servers = {
          codegraph = {
            args = [
              "serve"
              "--mcp"
            ];
            command = "codegraph";
            startup_timeout_sec = 8;
          };
          fff = {
            command = "fff-mcp";
            startup_timeout_sec = 8;
          };
          openaiDeveloperDocs.url = "https://developers.openai.com/mcp";
          qmd = {
            args = [ "mcp" ];
            command = "qmd";
            startup_timeout_sec = 8;
            tool_timeout_sec = 48;
          };
          semble = {
            command = "semble";
            startup_timeout_sec = 8;
            tool_timeout_sec = 96;
          };
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          safari-mcp = {
            args = [ "--mcp" ];
            command = "safaridriver";
          };
        };
        memories = {
          generate_memories = true;
          max_raw_memories_for_consolidation = 32;
          use_memories = true;
        };
        model = "gpt-6-sol";
        model_auto_compact_token_limit = 393216;
        model_context_window = 448000;
        model_reasoning_effort = "medium";
        model_reasoning_summary = "auto";
        model_verbosity = "medium";
        otel = {
          exporter = "none";
          metrics_exporter = "none";
          trace_exporter = "none";
        };
        personality = "pragmatic";
        sandbox_mode = "danger-full-access";
        sandbox_workspace_write = {
          exclude_slash_tmp = false;
          exclude_tmpdir_env_var = false;
          network_access = true;
        };
        shell_environment_policy = {
          ignore_default_excludes = false;
          "inherit" = "core";
        };
        tools = {
          view_image = true;
          web_search.context_size = "high";
        };
        tui = {
          alternate_screen = "auto";
          animations = true;
          notification_condition = "unfocused";
          notification_method = "auto";
          notifications = true;
          raw_output_mode = false;
          session_picker_view = "dense";
          show_tooltips = true;
          status_line = [
            "run-state"
            "task-progress"
            "model-with-reasoning"
            "fast-mode"
            "context-used"
            "context-window-size"
            "current-dir"
            "project-name"
            "git-branch"
            "branch-changes"
            "pull-request-number"
            "codex-version"
          ];
          status_line_use_colors = true;
          terminal_title = [
            "activity"
            "project"
          ];
        };
        web_search = "live";
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        notify = [
          "${config.home.homeDirectory}/.codex/computer-use/Codex Computer Use.app/Contents/SharedSupport/SkyComputerUseClient.app/Contents/MacOS/SkyComputerUseClient"
          "turn-ended"
        ];
      };
      enable = true;
    };

    lazyCodexAi = {
      codeGraph = true;
      context7 = false;
      enable = true;
    };
  };

  home.activation.cursorSafariMcp = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mcp_file="$HOME/.cursor/mcp.json"
      mkdir -p "$(dirname "$mcp_file")"
      if [ ! -f "$mcp_file" ]; then
        printf '%s\n' '{"mcpServers":{}}' > "$mcp_file"
      fi
      tmp_file="$(mktemp)"
      ${pkgs.jq}/bin/jq --arg command safaridriver '
        .mcpServers["safari-mcp"] = {"args": ["--mcp"], "command": $command}
      ' "$mcp_file" > "$tmp_file"
      mv "$tmp_file" "$mcp_file"
    ''
  );
}
