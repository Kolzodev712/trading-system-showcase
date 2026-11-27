#!/bin/sh
# Paper socket drop and runner trade-socket reconnect (not in-flight command replay).
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

clear_faults() {
  reset_lab_faults
}
trap clear_faults EXIT

echo "scenario exchange-disconnect"
reset_lab_faults
log_mark=$(compose logs runner --no-color 2>/dev/null | wc -l | tr -d ' ')

ops curl -fsS -o /dev/null -X POST http://k-paper:19999/test/disconnect_clients
sleep 2
logs=$(runner_logs_since "$log_mark")
echo "$logs" | grep -F 'k-paper: reconnecting trade WS' >/dev/null || {
  echo "BLOCKED disconnect was requested but the runner did not log a trade-socket reconnect" >&2
  exit 2
}
echo "ok   runner logged trade-socket reconnect"

deadline=$(( $(date +%s) + 60 ))
while [ "$(date +%s)" -lt "$deadline" ]; do
  logs=$(runner_logs_since "$log_mark")
  if echo "$logs" | grep -F 'k-paper: connected to' | grep -F '/ws/trade' >/dev/null; then
    echo "ok   runner logged trade-socket reconnected"
    echo "scenario exchange-disconnect: passed"
    exit 0
  fi
  sleep 3
done

echo "BLOCKED reconnect was logged but a post-reconnect trade connection was not observed within 60s" >&2
exit 2