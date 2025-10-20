set shell := ["nu", "-c"]

default:
    @just --list

[group('nix')]
ck:
    nix flake check -v --keep-going

[group('nix')]
fmt:
    nix fmt

[group('nix')]
updt:
    nix flake update --commit-lock-file
    git commit --amend -a

[group('nix')]
sw:
    nix flake show

[group('nix')]
repl:
    nix repl .

[group('nix')]
[linux]
hstry:
    nix profile history --profile /nix/var/nix/profiles/system

[group('nix')]
[linux]
gc:
    sudo nix-collect-garbage --delete-older-than 7d
    nix-collect-garbage --delete-older-than 7d

[group('nix')]
[linux]
gcroot:
    ls -al /nix/var/nix/gcroots/auto/

[group('nix')]
st-vrfy:
    nix store verify --all

[group('nix')]
st-rpr *paths:
    nix store repair {{ paths }}

[group('nixos')]
[linux]
bd host="current":
    let target = if "{{ host }}" == "current" { (^hostname | str trim) } else { "{{ host }}" }; \
    nix build $".#nixosConfigurations.($target).config.system.build.toplevel"

[group('nixos')]
[linux]
test host="current" flags="":
    let target = if "{{ host }}" == "current" { (^hostname | str trim) } else { "{{ host }}" }; \
    sudo nixos-rebuild test --flake $".#($target)" {{ flags }}

[group('nixos')]
[linux]
boot host="current" flags="":
    let target = if "{{ host }}" == "current" { (^hostname | str trim) } else { "{{ host }}" }; \
    sudo nixos-rebuild boot --flake $".#($target)" {{ flags }}

[group('nixos')]
[linux]
dry host="current":
    let target = if "{{ host }}" == "current" { (^hostname | str trim) } else { "{{ host }}" }; \
    sudo nixos-rebuild dry-activate --flake $".#($target)"

[group('dev')]
dev:
    nix develop -c nu

[group('dev')]
hook:
    pre-commit run --all-files -v

[group('dev')]
hook-istl:
    pre-commit install

[group('cfg')]
flk:
    ^$env.EDITOR flake.nix

[group('cfg')]
self:
    ^$env.EDITOR justfile

[group('prj')]
@info:
    ls -afm
    echo " "
    git --version
    git status

[group('git')]
gcaan:
    git commit --amend -a --no-edit

[group('git')]
git-gc:
    git reflog expire --expire-unreachable=now --all
    git gc --prune=now
