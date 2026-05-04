{
  flake,
  lib,
  pkgs,
  ...
}:
let
  llmAgents = flake.inputs.llm-agents;
  packages = llmAgents.packages or { };
  packageNames = [
    "codex"
    "gitnexus"
    "oh-my-opencode"
    "omp"
    "opencode"
    "qmd"
  ];
  systemKey = pkgs.stdenv.hostPlatform.system;
  systemPackages = packages.${systemKey};
  agentPackages = map (name: systemPackages.${name}) packageNames;
  desktopPackages = with pkgs; [
    opencode-desktop
  ];
in
{
  nix.settings = {
    extra-substituters = lib.mkAfter [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = lib.mkAfter [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  home.packages = agentPackages ++ desktopPackages;
}
