{
  flake,
  ...
}:
let
  inherit (flake.config) user;
in
{
  imports = [ flake.inputs.nixos-wsl.nixosModules.default ];
  wsl = {
    defaultUser = user.name;
    enable = true;
    startMenuLaunchers = true;
    useWindowsDriver = true;
  };
}
