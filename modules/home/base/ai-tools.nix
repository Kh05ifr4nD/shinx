{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  coolheaded = flake.inputs.coolheaded;
  llmAgents = flake.inputs.llm-agents.packages.${system};
  # nixpkgs publishes Cursor's CLI as cursor-cli; llm-agents.nix calls it cursor-agent.
  nixpkgsName = {
    cursor-agent = "cursor-cli";
  };
  pick = name: llmAgents.${name} or pkgs.${nixpkgsName.${name} or name};
  agentNames = [
    "claude-code"
    "codegraph"
    "cursor-agent"
    "entire"
    "fff-mcp"
    "rtk"
    "skills"
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    "omp"
  ];
in
{
  imports = [ coolheaded.homeModules.lazyCodexAi ];

  home.packages = map pick agentNames ++ [
    # Still published only by coolheaded.
    coolheaded.packages.${system}.zvecGrep
  ];

  programs = {
    codex = {
      package = pick "codex";
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
          view_image = true;
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
          zvecGrep = {
            args = [
              "server"
              "--stdio"
            ];
            command = "zg";
          };
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          safari = {
            args = [ "--mcp" ];
            command = "safaridriver";
          };
        };
        memories = {
          generate_memories = true;
          max_raw_memories_for_consolidation = 32;
          use_memories = true;
        };
        model = "gpt-6.1-sol";
        model_auto_compact_token_limit = 320000;
        model_context_window = 384000;
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
      context7 = false;
      enable = true;
    };
  };
}
