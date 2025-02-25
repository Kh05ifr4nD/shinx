{ ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        buildInputs = config.pre-commit.settings.enabledPackages;
        inputsFrom = with config; [
          flake-root.devShell
          treefmt.build.devShell
        ];
        name = "shinx";
        meta.description = "Home Manager & Nix Darwin & NixOS 配置";
        packages = with pkgs; [
          nixd
        ];
        shellhook = ''
          ${config.pre-commit.installationScript}
        '';
      };
    };
}
