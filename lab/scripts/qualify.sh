#!/bin/sh
# Cross-repo technical qualification. Does not duplicate trading_system just recipes.
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

echo "qualify: component + paper gates via trading_system justfile"
echo "  trading_system=$TRADING_SYSTEM_DIR"

if ! command -v just >/dev/null 2>&1; then
  echo "FAIL just is required" >&2
  exit 1
fi

cd "$TRADING_SYSTEM_DIR"
export K_PAPER_DIR UI_DIR

just test-fast
just test-5r-graph
just test-paper
just test-paper-negative
just test-paper-ui
just ci-local

echo "qualify: passed"
