{
  description = "NixOS & Nix Darwin & Home Manager 统一配置";
  inputs = {
    coolheaded = {
      inputs = {
        bun2nix.inputs = {
          flake-parts.follows = "flake-parts";
          nixpkgs.follows = "nixpkgs";
          systems.follows = "systems";
          treefmt-nix.follows = "treefmt-nix";
        };
        flakeParts.follows = "flake-parts";
        gitHooksNix.follows = "git-hooks-nix";
        nixpkgs.follows = "nixpkgs";
        treefmtNix.follows = "treefmt-nix";
      };
      url = "github:Kh05ifr4nD/coolheaded";
    };
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko/latest";
    };
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    flake-root.url = "github:srid/flake-root";
    git-hooks-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:cachix/git-hooks.nix";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    homebrew-brewforge-chinese = {
      flake = false;
      url = "github:Brewforge/homebrew-chinese";
    };
    homebrew-cask = {
      flake = false;
      url = "github:homebrew/homebrew-cask";
    };
    homebrew-core = {
      flake = false;
      url = "github:homebrew/homebrew-core";
    };
    musnix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:musnix/musnix";
    };
    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-darwin/nix-darwin/master";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-ld = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/nix-ld";
    };
    nix-vscode-extensions = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-vscode-extensions";
    };
    nixos-unified.url = "github:srid/nixos-unified";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
  };
  nixConfig = {
    connect-timeout = 4;
    download-attempts = 4;
    extra-substituters = [
      "https://cache.numtide.com"
      "https://cache.thalheim.io"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    fallback = true;
    stalled-download-timeout = 4;
    substituters = [
      "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store"
      "https://mirror.nju.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
  };
  outputs =
    {
      nixos-unified,
      ...
    }@inputs:
    nixos-unified.lib.mkFlake {
      inherit inputs;
      root = ./.;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    };
}
