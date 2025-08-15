{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
in
{
  programs.coolercontrol.enable = true;
}
