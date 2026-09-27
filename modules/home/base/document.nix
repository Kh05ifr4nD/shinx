{
  flake,
  lib,
  pkgs,
  ...
}:
let
  hostPlatform = pkgs.stdenv.hostPlatform;
  coolheadedPackages = flake.inputs.coolheaded.packages.${hostPlatform.system};
in
{
  home.packages = [
    coolheadedPackages.llp
    pkgs.mupdf-headless
  ]
  ++ lib.optionals hostPlatform.isLinux [ coolheadedPackages.minerUFull ];
}
