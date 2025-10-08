{ inputs, lib, ... }:
let
  sopsLib =
    if inputs.sops-nix ? lib then
      inputs.sops-nix.lib
    else if inputs.sops-nix ? outputs && inputs.sops-nix.outputs ? lib then
      inputs.sops-nix.outputs.lib
    else
      null;

  envSecretRaw = builtins.getEnv "SHINX_SECRETS_FILE";
  envSecretPath =
    if envSecretRaw == "" then
      null
    else if builtins.substring 0 1 envSecretRaw == "/" then
      envSecretRaw
    else
      lib.warn "Ignoring SHINX_SECRETS_FILE because it must be an absolute path." null;

  repoRoot = builtins.toString ../..;

  workdirRootRaw = builtins.getEnv "PWD";
  workdirRoot =
    if workdirRootRaw == "" then
      null
    else if lib.hasPrefix "/" workdirRootRaw then
      workdirRootRaw
    else
      null;

  mkCandidate = origin: description: path: {
    inherit origin description path;
  };

  repoCandidates = [
    (mkCandidate "repository" "secrets/cfg.secrets.yaml" "${repoRoot}/secrets/cfg.secrets.yaml")
    (mkCandidate "repository" "modules/flake/cfg.secrets.yaml"
      "${repoRoot}/modules/flake/cfg.secrets.yaml"
    )
  ];

  workdirCandidates =
    if workdirRoot != null && workdirRoot != repoRoot then
      [
        (mkCandidate "worktree" "worktree secrets/cfg.secrets.yaml"
          "${workdirRoot}/secrets/cfg.secrets.yaml"
        )
        (mkCandidate "worktree" "worktree modules/flake/cfg.secrets.yaml"
          "${workdirRoot}/modules/flake/cfg.secrets.yaml"
        )
      ]
    else
      [ ];

  envCandidates = lib.optional (envSecretPath != null) (
    mkCandidate "environment" "SHINX_SECRETS_FILE" envSecretPath
  );

  inputCandidates = lib.optional (inputs ? secrets) (
    mkCandidate "flake-input" "inputs.secrets/cfg.secrets.yaml" "${inputs.secrets}/cfg.secrets.yaml"
  );

  secretCandidates = envCandidates ++ inputCandidates ++ workdirCandidates ++ repoCandidates;

  resolveSecretCandidate =
    candidate:
    let
      candidateStr = toString candidate.path;
    in
    if builtins.pathExists candidateStr then
      candidate
      // {
        resolvedPath =
          if builtins.typeOf candidate.path == "path" then candidate.path else builtins.toPath candidateStr;
        resolvedPathString = candidateStr;
      }
    else
      null;

  secretCandidate = lib.findFirst (
    candidate: resolveSecretCandidate candidate != null
  ) null secretCandidates;

  resolvedSecret = if secretCandidate == null then null else resolveSecretCandidate secretCandidate;

  missingWarning =
    let
      checked = lib.concatStringsSep ", " (map (c: c.description) secretCandidates);
    in
    "No encrypted cfg.secrets.yaml found (checked ${checked}); using placeholder configuration.";

  decodeSecret =
    if resolvedSecret != null then
      let
        secretPath = resolvedSecret.resolvedPath;
        secretStr = resolvedSecret.resolvedPathString;
        trySops =
          if sopsLib != null then
            builtins.tryEval (sopsLib.evalSopsFile { file = secretPath; })
          else
            {
              success = false;
              value = null;
            };
        tryJson = builtins.tryEval (builtins.fromJSON (builtins.readFile secretStr));
        mkMeta =
          format: extra:
          {
            available = true;
            inherit format;
            path = secretStr;
            origin = resolvedSecret.origin;
            description = resolvedSecret.description;
          }
          // extra;
      in
      if trySops.success then
        {
          value = trySops.value;
          meta = mkMeta "sops" {
            fallback = false;
            fallbackReason = null;
          };
        }
      else if tryJson.success then
        {
          value = tryJson.value;
          meta = mkMeta "json" {
            fallback = true;
            fallbackReason = "sops-eval-failed";
          };
        }
      else
        let
          warnMsg = "Unable to decode cfg.secrets.yaml as either SOPS or plain JSON; using placeholder configuration.";
        in
        {
          value = lib.warn warnMsg { };
          meta = {
            available = false;
            format = "invalid";
            path = secretStr;
            origin = resolvedSecret.origin;
            description = resolvedSecret.description;
            fallback = true;
            fallbackReason = "invalid";
            warning = warnMsg;
          };
        }
    else
      {
        value = lib.warn missingWarning { };
        meta = {
          available = false;
          format = "missing";
          path = null;
          origin = null;
          description = null;
          fallback = true;
          fallbackReason = "missing";
          warning = missingWarning;
        };
      };

  secrets = decodeSecret.value;
  secretsMeta = decodeSecret.meta;

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
    secretsMeta = secretsMeta;
  };
}
