# See /modules/nixos/* for actual settings
# This file is just *top-level* configuration.
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    ./configuration.nix
    inputs.nixos-wsl.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    inputs.nix-ld.nixosModules.nix-ld
    self.nixosModules.default
  ];

  # Enable home-manager for "meandssh" user
  home-manager.users."meandssh" = {
    imports = [ (self + /configurations/home/meandssh.nix) ];
  };
}
