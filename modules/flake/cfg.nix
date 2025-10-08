{ inputs, lib, ... }:
let
  inherit (inputs) sops-nix;

  secretFile = ./cfg.secrets.yaml;
  secrets =
    if builtins.pathExists secretFile then
      sops-nix.lib.evalSopsFile { file = secretFile; }
    else
      lib.warn "No encrypted cfg.secrets.yaml found; using public placeholders." { };

  defaultUser = {
    name = "meandssh";
    git-name = "meandssh";
    full-name = "Kh05ifr4nD";
    email = "user@example.com";
    pub-key = "";
    gpg-key = null;
  };

  userSecret = lib.attrByPath [ "user" ] { } secrets;
  secretNetwork = lib.attrByPath [ "network" ] { } secrets;
  staticSecret = lib.attrByPath [ "staticIPv4" ] { } secretNetwork;
  sanitizedSecrets =
    secrets
    // { network = { staticIPv4 = staticSecret; }; };
in {
  config = {
    user = lib.recursiveUpdate defaultUser userSecret;
    secrets = sanitizedSecrets;
  };
}
