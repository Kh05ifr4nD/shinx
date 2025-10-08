{ inputs, lib, ... }:
let
  inherit (inputs) sops-nix;

  envSecretRaw = builtins.getEnv "SHINX_SECRETS_FILE";
  envSecretPath =
    if envSecretRaw == "" then
      null
    else if builtins.substring 0 1 envSecretRaw == "/" then
      envSecretRaw
    else
      lib.warn "Ignoring SHINX_SECRETS_FILE because it must be an absolute path." null;

  repoRoot = builtins.toString ../..;

  repoCandidates = [
    "${repoRoot}/secrets/cfg.secrets.yaml"
    "${repoRoot}/modules/flake/cfg.secrets.yaml"
  ];

  secretCandidates =
    lib.optional (envSecretPath != null) envSecretPath
    ++ lib.optional (inputs ? secrets) "${inputs.secrets}/cfg.secrets.yaml"
    ++ repoCandidates;

  resolveSecretCandidate =
    candidate:
    let
      candidateStr = toString candidate;
    in
    if builtins.pathExists candidateStr then
      if builtins.typeOf candidate == "path" then candidate else builtins.toPath candidateStr
    else
      null;

  secretFile = lib.findFirst (
    candidate: resolveSecretCandidate candidate != null
  ) null secretCandidates;

  secretPath = if secretFile == null then null else resolveSecretCandidate secretFile;

  secrets =
    if secretPath != null then
      sops-nix.lib.evalSopsFile { file = secretPath; }
    else
      lib.warn
        "No encrypted cfg.secrets.yaml found (checked SHINX_SECRETS_FILE, flake input `secrets`, secrets/cfg.secrets.yaml, modules/flake/cfg.secrets.yaml); using placeholder configuration."
        { };

  defaultUser = {
    name = "user";
    git-name = "user";
    full-name = "Example User";
    email = "user@example.com";
    pub-key = "";
    gpg-key = null;
  };

  userSecret = lib.attrByPath [ "user" ] { } secrets;
  secretNetwork = lib.attrByPath [ "network" ] { } secrets;
  staticSecret = lib.attrByPath [ "staticIPv4" ] { } secretNetwork;
  sanitizedSecrets = secrets // {
    network = {
      staticIPv4 = staticSecret;
    };
  };
in
{
  config = {
    user = lib.recursiveUpdate defaultUser userSecret;
    secrets = sanitizedSecrets;
  };
}
