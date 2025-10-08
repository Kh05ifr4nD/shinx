#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <encrypted-secret> <command> [args...]" >&2
  exit 2
fi

secret_path=$1
shift

if [[ ! -f "$secret_path" ]]; then
  exec "$@"
fi

tmp_file=$(mktemp)
cleanup() {
  rm -f "$tmp_file"
}
trap cleanup EXIT

if ! python scripts/secrets_cli.py decrypt --target "$secret_path" --input-type auto --output-type json >"$tmp_file"; then
  echo "warning: failed to decrypt secrets at $secret_path; running without SHINX_SECRETS_FILE" >&2
  rm -f "$tmp_file"
  trap - EXIT
  exec "$@"
fi

export SHINX_SECRETS_FILE="$tmp_file"
"$@"
