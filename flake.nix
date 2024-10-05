{
  description = "NixOS & Nix Darwin & Home Manager 统一配置";

  inputs = {
    # 核心 Flake
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    nixos-unified.url = "github:srid/nixos-unified";
    nixos-wsl = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/NixOS-WSL";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    # 秘密
    sops-nix.url = "github:Mic92/sops-nix";
    # 编辑器
    helix.url = "github:helix-editor/helix";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports =
        with builtins;
        map (fn: ./modules/flake-parts/${fn}) (attrNames (readDir ./modules/flake-parts));
      systems = import inputs.systems;
    };
}
