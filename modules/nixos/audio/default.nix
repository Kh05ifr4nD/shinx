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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  musnix.enable = true;
}
