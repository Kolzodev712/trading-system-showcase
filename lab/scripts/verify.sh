#!/bin/sh
# Read-only laboratory verification. Does not enable trading, place orders,
# inject faults, or alter account state.
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

echo "verify: read-only readiness and compatibility checks"

# Require a live stack — refuse to pass when services are down.
if ! curl -fsS --max-time 3 http://127.0.0.1:8080/health >/dev/null 2>&1; then
  echo "FAIL runner health endpoint not reachable on 127.0.0.1:8080 (is make demo running?)" >&2
  exit 1
fi
if ! curl -fsS --max-time 3 http://127.0.0.1:5173/ >/dev/null 2>&1; then
  echo "FAIL UI not reachable on 127.0.0.1:5173" >&2
  exit 1
fi

sh "$ROOT/scripts/validate-config.sh" "$ROOT/configurations/runner/bot.json"
echo "ok   paper isolation config"

# Prefer staged protos when present (release build), else live checkouts.
if [ -f "$ROOT/artifacts/build/trading_system/libs/trading_proto/proto/trading_cli.proto" ] \
  && [ -f "$ROOT/artifacts/build/trading-system-ui/proto/trading_cli.proto" ]; then
  if ! diff -q \
    "$ROOT/artifacts/build/trading_system/libs/trading_proto/proto/trading_cli.proto" \
    "$ROOT/artifacts/build/trading-system-ui/proto/trading_cli.proto" >/dev/null; then
    echo "FAIL staged protocol definitions differ" >&2
    exit 1
  fi
  echo "ok   staged protocol compatibility"
else
  sh "$ROOT/scripts/check-proto-compat.sh" >/dev/null
  echo "ok   protocol compatibility (live checkouts)"
fi

# Release mode: staged revisions must match compatibility.json pins.
if [ "$LAB_SOURCE_MODE" = "release" ] && [ -f "$ROOT/artifacts/build/STAGED_REVISIONS.json" ]; then
  python3 - "$ROOT/artifacts/build/STAGED_REVISIONS.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1]))
bad=[]
for name, info in data.get("components", {}).items():
    staged=info.get("staged")
    pinned=info.get("pinned")
    if not pinned:
        bad.append(f"{name}: missing pin")
    elif staged != pinned:
        bad.append(f"{name}: staged={staged} pinned={pinned}")
if bad:
    print("FAIL staged revisions do not match pins:", "; ".join(bad), file=sys.stderr)
    raise SystemExit(1)
print("ok   staged revisions match compatibility pins")
PY
fi

# Isolation probe must actually run. Missing clients must not pass.
if ! ops sh -c 'command -v curl >/dev/null'; then
  echo "FAIL ops image has no curl; cannot probe outbound connectivity" >&2
  exit 1
fi
if ops curl -fsS --max-time 3 http://1.1.1.1 >/dev/null 2>&1; then
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

auth_health=$(curl -fsS --max-time 5 http://127.0.0.1:5173/api/health || true)
echo "$auth_health" | grep -q '"ok":true\|"ok": true' || {
  echo "FAIL auth health: $auth_health" >&2
  exit 1
}
echo "ok   auth health"

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
case "$status" in
  *'"enabled": true'*|*'\"enabled\": true'*)
    echo "FAIL trading is enabled; read-only verify requires disabled trading" >&2
    exit 1
    ;;
esac
# grpcurl JSON may use enabled: true without quotes around true
if echo "$status" | python3 -c 'import json,sys; d=json.load(sys.stdin); raise SystemExit(0 if d.get("enabled") is False else 1)' 2>/dev/null; then
  echo "ok   trading disabled"
elif echo "$status" | grep -Eq '"enabled"[[:space:]]*:[[:space:]]*false'; then
  echo "ok   trading disabled"
else
  echo "FAIL could not confirm trading disabled from status: $status" >&2
  exit 1
fi

balances=$(ops curl -fsS --max-time 5 http://k-paper:19999/balances)
echo "$balances" | grep -q USDT || { echo "FAIL paper balances" >&2; exit 1; }
echo "ok   paper balances reachable"

info=$(ops curl -fsS --max-time 5 http://k-paper:19999/exchange_info)
echo "$info" | grep -q 'BTC-USDT' || { echo "FAIL exchange info" >&2; exit 1; }
echo "ok   paper exchange info"

ports=$(compose config --format json | python3 -c '
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
  raise SystemExit(1)
')
echo "ok   published ports appear loopback-bound in compose config"

echo "verify: passed (read-only)"
echo "note: use make scenario SCENARIO=normal-execution for a mutating demonstration"
