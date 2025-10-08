set shell := ["nu", "-c"]

@default: ls
    echo " "
    just --list

[group('dev')]
chk:
    nix flake check --impure --show-trace

[group('dev')]
dev:
    nix develop --show-trace -c nu

[group('cfg')]
flake:
    ^$env.EDITOR flake.nix

[group('dev')]
fmt:
    nix fmt --show-trace

[group('ci')]
fmt-check:
    nix fmt -- --fail-on-change

[group('prj')]
@ls:
    ls -afm
    echo " "
    git --version
    git status

[group('main')]
run: fmt chk
    nix run --show-trace

[group('cfg')]
self:
    ^$env.EDITOR justfile

[group('dev')]
upd:
    nix flake update

[group('secrets')]
secrets-age-key key_path="~/.config/sops/age/keys.txt":
    python scripts/secrets_cli.py age-key --key-path "{{ key_path }}"

secrets-encrypt recipients source="secrets/cfg.secrets.yaml.example" target="secrets/cfg.secrets.yaml":
    bash -lc "python scripts/secrets_cli.py encrypt --recipients {{ recipients }} --source '{{ source }}' --target '{{ target }}'"

secrets-decrypt target="secrets/cfg.secrets.yaml":
    python scripts/secrets_cli.py decrypt --target "{{ target }}"

secrets-edit target="secrets/cfg.secrets.yaml" recipients="":
    bash -lc "python scripts/secrets_cli.py edit --target '{{ target }}' --recipients {{ recipients }}"

secrets-smoke source="secrets/cfg.secrets.yaml.example":
    nix run .#secrets-smoke -- --source "{{ source }}"

secrets-check target="secrets/cfg.secrets.yaml":
    nix flake check --impure --show-trace
    python scripts/secrets_cli.py decrypt --target "{{ target }}" >/dev/null

secrets-materialize source="secrets/cfg.secrets.yaml" target=".direnv/secrets/cfg.secrets.json":
    python scripts/secrets_cli.py materialize --source "{{ source }}" --target "{{ target }}"

[group('ci')]
ci: fmt-check chk
    nix run .#secrets-smoke

[group('ci')]
om-ci:
    nix develop .#default --command env NIX_CONFIG="experimental-features = nix-command flakes" om ci run . --no-link
