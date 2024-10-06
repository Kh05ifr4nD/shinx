# Default command when 'just' is run without arguments
default:
  @just --list

# Update nix flake
[group('main')]
update:
  nix flake update

# Lint nix files
[group('dev')]
lint:
  nix fmt

# Check nix flake
[group('dev')]
check:
  nix flake check

# Manually enter dev shell
[group('dev')]
dev:
  nix develop

# Activate the configuration
[group('main')]
run: lint check
  nix run
