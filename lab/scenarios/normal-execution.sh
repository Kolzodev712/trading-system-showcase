#!/bin/sh
# Connectivity plus a newly placed runner order correlated with a place ACK (or fill).
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

baseline_orders=$(ops curl -fsS 'http://k-paper:19999/open_orders?instrument_id=BTC-USDT' || true)
baseline_trades=$(ops curl -fsS 'http://k-paper:19999/trades?limit=50' || true)
baseline_order_ids=$(paper_order_ids "$baseline_orders")
baseline_trade_ids=$(paper_order_ids "$baseline_trades")
log_mark=$(compose logs runner --no-color 2>/dev/null | wc -l | tr -d ' ')

status=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{}' runner:50051 trading_cli.TradingCliService/GetTradingStatus)
echo "$status" | grep -q '"enabled": true' || {
  echo "trading starts disabled; enabling through the runner control plane"
  ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
    -d '{"enabled":true}' runner:50051 trading_cli.TradingCliService/SetTradingEnabled
}

correlate_new_order() {
  _id=$1
  _runner_logs=$2
  echo "$_runner_logs" | grep -F "ack_exchange_id=${_id}" >/dev/null \
    && return 0
  echo "$_runner_logs" | grep -F 'k-paper: sent place_order' >/dev/null \
    && echo "$_runner_logs" | grep -F "order_id=${_id}" >/dev/null \
    && return 0
  return 1
}

deadline=$(( $(date +%s) + 180 ))
while [ "$(date +%s)" -lt "$deadline" ]; do
  runner_logs=$(runner_logs_since "$log_mark")
  orders=$(ops curl -fsS 'http://k-paper:19999/open_orders?instrument_id=BTC-USDT' || true)
  for id in $(paper_order_ids "$orders"); do
    if id_is_new "$id" "$baseline_order_ids" && correlate_new_order "$id" "$runner_logs"; then
      echo "ok   new paper order $id correlated with runner place evidence"
      echo "scenario normal-execution: passed"
      exit 0
    fi
  done
  trades=$(ops curl -fsS 'http://k-paper:19999/trades?limit=50' || true)
  for id in $(paper_order_ids "$trades"); do
    if id_is_new "$id" "$baseline_trade_ids" && correlate_new_order "$id" "$runner_logs"; then
      echo "ok   new paper trade for order $id correlated with runner place evidence"
      echo "scenario normal-execution: passed"
      exit 0
    fi
  done
  sleep 5
done

echo "BLOCKED no new runner order correlated with ack or execution within 180s" >&2
echo "Baseline open-order ids were not sufficient; stale orders alone do not pass." >&2
echo "Inspect runner logs for indicator warmup or risk blocks." >&2
exit 2