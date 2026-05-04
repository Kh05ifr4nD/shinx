{ lib, ... }:

let
  proxyEnv = import ../../proxy-env.nix { inherit lib; };
in
{
  launchd.user.envVariables = proxyEnv;
  nix.envVars = proxyEnv;
}
