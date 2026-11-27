#!/bin/sh
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

echo "scenario risk-rejection"
restore_profile() {
  export SHOWCASE_PROFILE=normal
  compose up -d --no-build --pull never --force-recreate --no-deps runner >/dev/null
}
trap restore_profile EXIT
export SHOWCASE_PROFILE=risk-rejection
compose up -d --no-build --pull never --force-recreate --no-deps runner
i=0
while [ "$i" -lt 40 ]; do
  if curl -fsS http://127.0.0.1:8080/health >/dev/null 2>&1; then
    break
  fi
  i=$((i + 1))
  sleep 3
done
ops grpcurl -plaintext -import-path /proto -proto trading_cli.proto \
  -d '{"enabled":true}' runner:50051 trading_cli.TradingCliService/SetTradingEnabled >/dev/null

deadline=$(( $(date +%s) + 180 ))
while [ "$(date +%s)" -lt "$deadline" ]; do
  logs=$(compose logs runner --since 3m --no-color 2>/dev/null || true)
  if echo "$logs" | grep -F 'blocked by risk check' >/dev/null; then
    echo "ok   runner logged a risk block"
    echo "scenario risk-rejection: passed"
    exit 0
  fi
  sleep 5
done
echo "BLOCKED no risk-block log line within 180s. The level may not have reached a pre-trade check yet." >&2
exit 2
