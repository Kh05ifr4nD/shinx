{ inputs, lib, ... }:
let
  inherit (lib.strings) hasInfix hasSuffix toLower;

  envSecretRaw = builtins.getEnv "SHINX_SECRETS_FILE";
  envSecretPath =
    if envSecretRaw == "" then
      null
    else if builtins.substring 0 1 envSecretRaw == "/" then
      envSecretRaw
    else
      lib.warn "Ignoring SHINX_SECRETS_FILE because it must be an absolute path." null;

  repoRoot = builtins.toString ../..;

  worktreeRaw =
    let
      override = builtins.getEnv "SHINX_WORKTREE";
    in
    if override != "" then override else builtins.getEnv "PWD";

  worktreePath =
    if worktreeRaw != "" && builtins.substring 0 1 worktreeRaw == "/" then worktreeRaw else null;

  worktreeCandidates = lib.optionals (worktreePath != null) [
    "${worktreePath}/.direnv/secrets/cfg.secrets.json"
    "${worktreePath}/secrets/cfg.secrets.json"
    "${worktreePath}/secrets/cfg.secrets.yaml"
    "${worktreePath}/modules/flake/cfg.secrets.yaml"
  ];

  repoCandidates = [
    "${repoRoot}/secrets/cfg.secrets.yaml"
    "${repoRoot}/modules/flake/cfg.secrets.yaml"
  ];

  secretCandidates =
    lib.optional (envSecretPath != null) envSecretPath
    ++ lib.optional (inputs ? secrets) "${inputs.secrets}/cfg.secrets.yaml"
    ++ worktreeCandidates
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

  isSopsEncrypted = content: lib.hasInfix "sops:" content && lib.hasInfix "ENC[" content;

  readSecrets =
    path:
    let
      pathStr = toString path;
      content = builtins.readFile pathStr;
      lowerPath = toLower pathStr;
    in
    if isSopsEncrypted content then
      lib.warn
        "${pathStr} 看起来仍是 SOPS 密文，请先运行 `just secrets-materialize` 或设置 SHINX_SECRETS_FILE 指向解密后的 JSON/Nix 文件。"
        { }
    else if hasSuffix ".json" lowerPath then
      builtins.fromJSON content
    else if hasSuffix ".nix" lowerPath then
      import path
    else
      lib.warn "不支持的密文格式 ${pathStr}，请提供 JSON（推荐）或 Nix 表达式。" { };

  secrets =
    if secretPath != null then
      readSecrets secretPath
    else
      lib.warn
        "No cfg.secrets file found (checked SHINX_SECRETS_FILE, flake input `secrets`, worktree/materialized paths); using placeholder configuration."
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
