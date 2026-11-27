#!/bin/sh
# Arms suppress_place_ack only; automated recovery is not demonstrated.
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

clear_faults() {
  reset_lab_faults
}
trap clear_faults EXIT

echo "scenario lost-ack"
code=$(ops curl -s -o /dev/null -w '%{http_code}' -X POST http://k-paper:19999/test/suppress_place_ack \
  -H 'content-type: application/json' -d '{}')
if [ "$code" != "204" ]; then
  echo "FAIL suppress_place_ack returned $code" >&2
  exit 1
fi
echo "info armed k-paper suppress_place_ack for the next place (hook only; not a pass)"
echo "BLOCKED this run does not wait for a new runner order and a recovery import." >&2
echo "Historical qualification of that recovery restarted the runner while k-paper kept the order." >&2
echo "That restart is not automated here, so recovery is not claimed." >&2
echo "info clearing lab faults before exit"
exit 2