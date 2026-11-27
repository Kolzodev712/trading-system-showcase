#!/bin/sh
# Startup bootstrap reconciliation log lines only (no planted mismatch).
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

echo "scenario reconciliation"
logs=$(compose logs runner --no-color 2>/dev/null || true)
# Runner logs: "Exchange Engine: Bootstrap reconciliation completed"
# (start line may be absent; completion is the observable evidence).
echo "$logs" | grep -F 'Bootstrap reconciliation completed' >/dev/null || {
  echo "BLOCKED bootstrap reconciliation completion was not logged" >&2
  exit 2
}
echo "ok   bootstrap reconciliation completed"
echo "scenario reconciliation: passed (startup path only; a planted mismatch is not claimed)"