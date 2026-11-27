#!/bin/sh
# Connectivity plus whatever order evidence the live level runner has produced.
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

echo "scenario normal-execution"

logs=$(compose logs runner --no-color 2>/dev/null || true)
echo "$logs" | grep -F 'k-paper: connected to' >/dev/null || {
  echo "FAIL runner has not logged a k-paper trade connection" >&2
  exit 1
}
echo "$logs" | grep -F 'k-paper market data: connected to' >/dev/null || {
  echo "FAIL runner has not logged a k-paper market-data connection" >&2
  exit 1
}
echo "ok   runner connected to paper trade and market sockets"

balances=$(ops curl -fsS http://k-paper:19999/balances)
echo "$balances" | grep -q USDT || { echo "FAIL paper balances" >&2; exit 1; }
echo "ok   paper balances"

info=$(ops curl -fsS http://k-paper:19999/exchange_info)
echo "$info" | grep -q 'BTC-USDT' || { echo "FAIL exchange info" >&2; exit 1; }
echo "ok   paper exchange info"

status=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{}' runner:50051 trading_cli.TradingCliService/GetTradingStatus)
echo "$status" | grep -q '"enabled": true' || {
  echo "trading starts disabled; enabling through the runner control plane"
  ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
    -d '{"enabled":true}' runner:50051 trading_cli.TradingCliService/SetTradingEnabled
}

deadline=$(( $(date +%s) + 180 ))
while [ "$(date +%s)" -lt "$deadline" ]; do
  state=$(ops curl -fsS http://runner:8080/state || true)
  orders=$(ops curl -fsS 'http://k-paper:19999/open_orders?instrument_id=BTC-USDT' || true)
  trades=$(ops curl -fsS 'http://k-paper:19999/trades?limit=5' || true)
  active=$(printf '%s' "$state" | sed -n 's/.*"active_orders":\([0-9]*\).*/\1/p')
  pending=$(printf '%s' "$state" | sed -n 's/.*"pending_orders":\([0-9]*\).*/\1/p')
  if [ "${active:-0}" != "0" ] || [ "${pending:-0}" != "0" ]; then
    echo "ok   runner state shows orders: $state"
    echo "scenario normal-execution: passed"
    exit 0
  fi
  if [ "$orders" != "[]" ] && [ -n "$orders" ]; then
    echo "ok   paper open orders: $orders"
    echo "scenario normal-execution: passed"
    exit 0
  fi
  if [ "$trades" != "[]" ] && [ -n "$trades" ] && echo "$trades" | grep -q orderId; then
    echo "ok   paper trades: $trades"
    echo "scenario normal-execution: passed"
    exit 0
  fi
  sleep 5
done

echo "BLOCKED no runner order or paper fill was observed within 180s" >&2
echo "runner /state was: ${state:-unknown}" >&2
echo "This scenario does not invent an order. Inspect runner logs for indicator warmup or risk blocks." >&2
exit 2
