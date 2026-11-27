#!/bin/sh
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

echo "scenario exchange-disconnect"
ops curl -fsS -o /dev/null -X POST http://k-paper:19999/test/disconnect_clients
sleep 8
logs=$(compose logs runner --since 1m --no-color 2>/dev/null || true)
echo "$logs" | grep -F 'k-paper: reconnecting trade WS' >/dev/null || {
  echo "BLOCKED disconnect was requested but the runner did not log a trade-socket reconnect" >&2
  exit 2
}
echo "ok   runner logged trade-socket reconnect"
echo "scenario exchange-disconnect: passed"
