set shell := ["nu", "-c"]

@default: ls
    echo " "
    just --list

[group('dev')]
chk:
    nix flake check --show-trace

[group('dev')]
dev:
    nix develop --show-trace -c nu

[group('cfg')]
flake:
    ^$env.EDITOR flake.nix

[group('dev')]
fmt:
    nix fmt --show-trace

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
