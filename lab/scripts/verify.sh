#!/bin/sh
# Read-only laboratory verification. Does not enable trading, place orders,
# inject faults, or alter account state.
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

echo "verify: read-only readiness and compatibility checks"

sh "$ROOT/scripts/validate-config.sh" "$ROOT/configurations/runner/bot.json"
echo "ok   paper isolation config"

if sh "$ROOT/scripts/check-proto-compat.sh" >/dev/null; then
  echo "ok   protocol compatibility"
else
  echo "FAIL protocol compatibility" >&2
  exit 1
fi

# Weak signal only: one outbound HTTP probe after masquerade disabled.
# This does not prove comprehensive network isolation by itself.
if ops wget -q -O- --timeout=3 http://1.1.1.1 >/dev/null 2>&1; then
  echo "FAIL containers can reach the public internet via HTTP" >&2
  exit 1
fi
echo "ok   internal network blocked one outbound HTTP probe (not full isolation proof)"

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
echo "ok   auth login (laboratory demonstration credentials)"

status=$(ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{}' runner:50051 trading_cli.TradingCliService/GetTradingStatus)
echo "$status" | grep -q 'PAPER' || { echo "FAIL venue is not PAPER: $status" >&2; exit 1; }
echo "$status" | grep -q 'LOCAL' || { echo "FAIL environment is not LOCAL: $status" >&2; exit 1; }
echo "ok   runner reports PAPER LOCAL"

# Trading must remain disabled for read-only verify.
if echo "$status" | grep -q '"enabled": true'; then
  echo "FAIL trading is enabled; read-only verify requires disabled trading" >&2
  exit 1
fi
echo "ok   trading disabled"

# Market-data connectivity without mutating orders.
balances=$(ops curl -fsS --max-time 5 http://k-paper:19999/balances)
echo "$balances" | grep -q USDT || { echo "FAIL paper balances" >&2; exit 1; }
echo "ok   paper balances reachable"

info=$(ops curl -fsS --max-time 5 http://k-paper:19999/exchange_info)
echo "$info" | grep -q 'BTC-USDT' || { echo "FAIL exchange info" >&2; exit 1; }
echo "ok   paper exchange info"

# Intended host exposure: only loopback operator ports (best-effort check via compose config).
ports=$(compose config --format json 2>/dev/null | python3 -c '
import json,sys
cfg=json.load(sys.stdin)
bad=[]
for name,svc in cfg.get("services",{}).items():
  for p in svc.get("ports") or []:
    published=str(p.get("published",""))
    host=str(p.get("host_ip") or "")
    if published and host not in ("127.0.0.1","localhost"):
      bad.append("%s:%s:%s" % (name, host or "*", published))
if bad:
  print(" ".join(bad))
' || true)
if [ -n "${ports:-}" ]; then
  echo "FAIL non-loopback published ports: $ports" >&2
  exit 1
fi
echo "ok   published ports appear loopback-bound in compose config"

echo "verify: passed (read-only)"
echo "note: use make scenario SCENARIO=normal-execution for a mutating demonstration"
