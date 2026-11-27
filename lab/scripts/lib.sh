#!/bin/sh
# Shared helpers. Source from other scripts; do not execute directly.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$ROOT"

if [ -f "$ROOT/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$ROOT/.env"
  set +a
fi

compose() {
  docker compose --project-directory "$ROOT" -f "$ROOT/compose.yaml" "$@"
}

ops() {
  compose exec -T ops "$@"
}
