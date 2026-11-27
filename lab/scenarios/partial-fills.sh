#!/bin/sh
# Laboratory partial fill on a runner order with log correlation and post-fill REST state.
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

echo "scenario partial-fills"

pick_runner_order() {
  _orders=$1
  _ids=$(paper_order_ids "$_orders")
  _runner_logs=$(runner_logs_since 0)
  for id in $_ids; do
    if echo "$_runner_logs" | grep -F "ack_exchange_id=${id}" >/dev/null \
      || echo "$_runner_logs" | grep -F "OrderId(\"${id}\")" >/dev/null \
      || echo "$_runner_logs" | grep -F "$id" >/dev/null; then
      printf '%s' "$id"
      return 0
    fi
  done
  return 1
}

filled_amount_for() {
  _json=$1
  _id=$2
  printf '%s' "$_json" | python3 -c '
import json, sys
needle = sys.argv[1]
for row in json.load(sys.stdin):
    if row.get("orderId") == needle:
        print(row.get("filledAmount", ""))
        raise SystemExit(0)
raise SystemExit(1)
' "$_id"
}

deadline=$(( $(date +%s) + 120 ))
id=
while [ "$(date +%s)" -lt "$deadline" ]; do
  orders=$(ops curl -fsS 'http://k-paper:19999/open_orders?instrument_id=BTC-USDT')
  id=$(pick_runner_order "$orders") || true
  if [ -n "${id:-}" ]; then
    break
  fi
  sleep 5
done
if [ -z "${id:-}" ]; then
  echo "BLOCKED no resting BTC-USDT runner order to partially fill" >&2
  echo "Run normal-execution first or wait for levels mode to post." >&2
  exit 2
fi

filled_before=$(filled_amount_for "$orders" "$id" || true)
filled_before=${filled_before:-0}

result=$(ops curl -fsS -X POST http://k-paper:19999/test/lab_fill_open \
  -H 'content-type: application/json' \
  -d "{\"qty\":\"0.001\",\"order_id\":\"$id\"}")
echo "$result"
echo "$result" | grep -q '"filled_qty":"0.001"' || {
  echo "FAIL partial fill response did not show filled_qty 0.001" >&2
  exit 1
}

orders_after=$(ops curl -fsS 'http://k-paper:19999/open_orders?instrument_id=BTC-USDT')
filled_after=$(filled_amount_for "$orders_after" "$id") || {
  echo "FAIL open_orders no longer contains order $id after partial fill" >&2
  exit 1
}
if [ "$filled_after" = "$filled_before" ]; then
  echo "FAIL filledAmount unchanged after partial fill ($filled_before)" >&2
  exit 1
fi
case "$filled_before" in
  0|0.000|0.0000) ;;
  *)
    echo "ok   prior filledAmount before hook: $filled_before" ;;
esac
echo "ok   filledAmount after hook: $filled_after (order $id)"
echo "scenario partial-fills: passed"