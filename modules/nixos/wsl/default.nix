{
  flake,
  usr,
  ...
}:
let
  inherit (flake) inputs;
in
{
  imports = [ inputs.nixos-wsl.nixosModules.default ];
  wsl = {
    defaultUser = usr;
    enable = true;
    startMenuLaunchers = true;
    useWindowsDriver = true;
  };
}
