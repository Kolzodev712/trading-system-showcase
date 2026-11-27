#!/bin/sh
# PauseEntries and Resume through gRPC with status before, during, and after.
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

entries_paused_true() {
  printf '%s' "$1" | python3 -c 'import json,sys; d=json.load(sys.stdin); raise SystemExit(0 if d.get("entriesPaused") is True else 1)'
}

# proto3 JSON omits default false — missing entriesPaused means unpaused.
entries_paused_false() {
  printf '%s' "$1" | python3 -c 'import json,sys; d=json.load(sys.stdin); raise SystemExit(0 if d.get("entriesPaused") is not True else 1)'
}

echo "scenario operator-control"
before=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{}' runner:50051 trading_cli.TradingCliService/GetTradingStatus)
entries_paused_false "$before" || {
  echo "FAIL expected entries unpaused before pause: $before" >&2
  exit 1
}

pause=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{"request_id":"showcase-pause","symbol":""}' \
  runner:50051 trading_cli.TradingCliService/PauseEntries)
echo "$pause" | grep -q '"accepted": true' || {
  echo "FAIL PauseEntries: $pause" >&2
  exit 1
}
status=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{}' runner:50051 trading_cli.TradingCliService/GetTradingStatus)
entries_paused_true "$status" || {
  echo "FAIL status after pause: $status" >&2
  exit 1
}
echo "ok   entries paused"

resume=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{"request_id":"showcase-resume","symbol":""}' \
  runner:50051 trading_cli.TradingCliService/Resume)
echo "$resume" | grep -q '"accepted": true' || {
  echo "FAIL Resume: $resume" >&2
  exit 1
}
status=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{}' runner:50051 trading_cli.TradingCliService/GetTradingStatus)
entries_paused_false "$status" || {
  echo "FAIL status after resume: $status" >&2
  exit 1
}
echo "ok   entries resumed"
echo "scenario operator-control: passed"