{
  flake,
  pkgs,
  ...
}:

let
  inherit (flake) inputs;
in
{
  imports =
    with builtins;
    map (f: ./${f}) (filter (f: f != "default.nix") (attrNames (readDir ./.)))
    ++ (with inputs; [
      musnix.nixosModules.musnix
    ]);
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
}
