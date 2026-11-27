#!/bin/sh
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

echo "verify: isolation, connectivity, and one trading observation"

if ops wget -q -O- --timeout=3 http://1.1.1.1 >/dev/null 2>&1; then
  echo "FAIL containers can reach the public internet" >&2
  exit 1
fi
echo "ok   internal network has no public HTTP route"

health=$(curl -fsS --max-time 5 http://127.0.0.1:8080/health)
echo "$health" | grep -q '"status":"healthy"' || {
  echo "FAIL runner health: $health" >&2
  exit 1
}
echo "ok   runner /health"

curl -fsS --max-time 5 http://127.0.0.1:5173/ >/dev/null
echo "ok   ui"

login=$(curl -fsS --max-time 5 -X POST http://127.0.0.1:5173/api/auth/login \
  -H 'content-type: application/json' \
  -d '{"username":"admin","password":"admin"}')
echo "$login" | grep -q '"token"' || {
  echo "FAIL auth login" >&2
  exit 1
}
echo "ok   auth login"

status=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{}' runner:50051 trading_cli.TradingCliService/GetTradingStatus)
echo "$status" | grep -q 'PAPER' || { echo "FAIL venue is not PAPER: $status" >&2; exit 1; }
echo "$status" | grep -q 'LOCAL' || { echo "FAIL environment is not LOCAL: $status" >&2; exit 1; }
echo "ok   runner reports PAPER LOCAL"
echo "$status"

sh "$ROOT/scenarios/normal-execution.sh"
echo "verify: passed"
