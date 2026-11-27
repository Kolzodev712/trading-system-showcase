#!/bin/sh
# Uses k-paper's laboratory fill hook on an order the runner already placed.
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

echo "scenario partial-fills"
orders=$(ops curl -fsS 'http://k-paper:19999/open_orders?instrument_id=BTC-USDT')
id=$(printf '%s' "$orders" | sed -n 's/.*"orderId":"\([^"]*\)".*/\1/p' | head -n 1)
if [ -z "$id" ]; then
  echo "BLOCKED no resting BTC-USDT order to partially fill" >&2
  exit 2
fi
result=$(ops curl -fsS -X POST http://k-paper:19999/test/lab_fill_open \
  -H 'content-type: application/json' \
  -d "{\"qty\":\"0.001\",\"order_id\":\"$id\"}")
echo "$result"
echo "$result" | grep -q '"filled_qty":"0.001"' || {
  echo "FAIL partial fill response did not show filled_qty 0.001" >&2
  exit 1
}
echo "ok   laboratory partial fill of runner order $id"
echo "scenario partial-fills: passed"
