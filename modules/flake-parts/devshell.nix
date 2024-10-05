{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "shinx";
      meta.description = "NixOS & Nix Darwin & Home Manager 统一配置";
      packages = with pkgs; [
        just
        nixd
        nixfmt-rfc-style
      ];
    };
  };
}
