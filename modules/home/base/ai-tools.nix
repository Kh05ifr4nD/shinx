{
  flake,
  lib,
  pkgs,
  ...
}:
let
  coolheaded = flake.inputs.coolheaded;
  packages = coolheaded.packages or { };
  packageNames = [
    "codex"
    "entire"
    "opencode"
    "qmd"
    "rtk"
  ];
  systemKey = pkgs.stdenv.hostPlatform.system;
  systemPackages = packages.${systemKey};
  agentPackages = map (name: systemPackages.${name}) packageNames;
  desktopPackages = lib.optionals (!pkgs.stdenv.isDarwin) (
    with pkgs;
    [
      opencode-desktop
    ]
  );
  localInferencePackages = [
    pkgs.llama-cpp
  ]
  ++ lib.optionals (pkgs.stdenv.isDarwin && pkgs.stdenv.hostPlatform.isAarch64) [
    pkgs.python3Packages.mlx-lm
  ];
in
{
  home.packages = agentPackages ++ desktopPackages ++ localInferencePackages;
}
