#!/bin/sh
# Shared helpers. Source from other scripts; do not execute directly.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$ROOT"

# Sibling layout (paths relative to lab/):
#   workspace/{trading_system,k-paper,trading-system-ui,trading-system-showcase/lab}
DEFAULT_TRADING_SYSTEM_DIR=../../trading_system
DEFAULT_K_PAPER_DIR=../../k-paper
DEFAULT_UI_DIR=../../trading-system-ui

if [ -f "$ROOT/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$ROOT/.env"
  set +a
fi

: "${TRADING_SYSTEM_DIR:=$DEFAULT_TRADING_SYSTEM_DIR}"
: "${K_PAPER_DIR:=$DEFAULT_K_PAPER_DIR}"
: "${UI_DIR:=$DEFAULT_UI_DIR}"
: "${LAB_SOURCE_MODE:=release}"

# Resolve a path. Relative paths are relative to ROOT (lab/). Absolute paths kept.
resolve_dir() {
  _p=$1
  case "$_p" in
    /*)
      printf '%s\n' "$_p"
      ;;
    *)
      if [ ! -d "$ROOT/$_p" ] && [ ! -e "$ROOT/$_p" ]; then
        printf '%s\n' "$ROOT/$_p"
        return 0
      fi
      CDPATH= cd -- "$ROOT/$_p" && pwd
      ;;
  esac
}

TRADING_SYSTEM_DIR=$(resolve_dir "$TRADING_SYSTEM_DIR")
K_PAPER_DIR=$(resolve_dir "$K_PAPER_DIR")
UI_DIR=$(resolve_dir "$UI_DIR")
export TRADING_SYSTEM_DIR K_PAPER_DIR UI_DIR LAB_SOURCE_MODE ROOT

compose() {
  # Prefer absolute component paths so compose works regardless of cwd.
  TRADING_SYSTEM_DIR="$TRADING_SYSTEM_DIR" \
  K_PAPER_DIR="$K_PAPER_DIR" \
  UI_DIR="$UI_DIR" \
  docker compose --project-directory "$ROOT" -f "$ROOT/compose.yaml" "$@"
}

ops() {
  compose exec -T ops "$@"
}

# Sorted unique orderId values from k-paper open_orders or trades JSON.
paper_order_ids() {
  printf '%s' "$1" | sed -n 's/.*"orderId":"\([^"]*\)".*/\1/p' | sort -u
}

# Return 0 when id is absent from a newline-separated baseline id list.
id_is_new() {
  _id=$1
  _list=$2
  [ -z "$_list" ] && return 0
  printf '%s\n' "$_list" | grep -qxF "$_id" && return 1
  return 0
}

# Clear k-paper one-shot lab hooks so later runs are not polluted.
reset_lab_faults() {
  code=$(ops curl -s -o /dev/null -w '%{http_code}' -X POST http://k-paper:19999/test/reset_lab_faults \
    -H 'content-type: application/json' -d '{}' || true)
  if [ "$code" != "204" ]; then
    echo "WARN reset_lab_faults returned ${code:-unknown}" >&2
  fi
}

# Runner log lines appended after scenario $1 (line count at start).
runner_logs_since() {
  _skip=$1
  compose logs runner --no-color 2>/dev/null | tail -n +"$((_skip + 1))"
}
