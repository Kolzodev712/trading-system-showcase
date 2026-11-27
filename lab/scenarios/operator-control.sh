#!/bin/sh
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

echo "scenario operator-control"
pause=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{"request_id":"showcase-pause","symbol":""}' \
  runner:50051 trading_cli.TradingCliService/PauseEntries)
echo "$pause" | grep -q '"accepted": true' || {
  echo "FAIL PauseEntries: $pause" >&2
  exit 1
}
status=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{}' runner:50051 trading_cli.TradingCliService/GetTradingStatus)
echo "$status" | grep -q '"entriesPaused": true' || echo "$status" | grep -q '"entries_paused": true' || {
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
echo "ok   entries resumed"
echo "scenario operator-control: passed"
