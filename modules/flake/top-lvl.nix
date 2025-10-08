{ inputs, ... }:
{
  imports =
    with inputs.nixos-unified.flakeModules;
    [
      autoWire
      default
    ]
    ++ (with inputs; [
      flake-root.flakeModule
      git-hooks-nix.flakeModule
      treefmt-nix.flakeModule
    ]);
  perSystem =
    { pkgs, self', ... }:
    {
      packages.default = self'.packages.activate;
      apps.secrets-smoke = {
        type = "app";
        program =
          (pkgs.writeShellApplication {
            name = "secrets-smoke";
            runtimeInputs = with pkgs; [
              age
              python3
              sops
            ];
            text = ''
              set -euo pipefail
              python ${../../scripts/secrets_cli.py} smoke "$@"
            '';
          }).outPath
          + "/bin/secrets-smoke";
      };
    };
}
