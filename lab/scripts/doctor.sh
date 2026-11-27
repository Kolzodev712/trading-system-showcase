#!/bin/sh
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

fail=0
note() { printf '  %s\n' "$1"; }
bad() { printf '  FAIL %s\n' "$1"; fail=1; }
ok() { printf '  ok   %s\n' "$1"; }

echo "doctor: demonstration prerequisites"

command -v docker >/dev/null 2>&1 && ok "docker" || bad "docker is not installed"
docker info >/dev/null 2>&1 && ok "docker daemon" || bad "docker daemon is not reachable"
docker compose version >/dev/null 2>&1 && ok "docker compose" || bad "docker compose is not installed"

for pair in \
  "TRADING_SYSTEM_DIR:${TRADING_SYSTEM_DIR:-}" \
  "K_PAPER_DIR:${K_PAPER_DIR:-}" \
  "UI_DIR:${UI_DIR:-}"
do
  name=${pair%%:*}
  path=${pair#*:}
  if [ -z "$path" ]; then
    bad "$name is unset"
    continue
  fi
  if [ ! -d "$ROOT/$path" ] && [ ! -d "$path" ]; then
    bad "$name does not exist ($path)"
  else
    ok "$name ($path)"
  fi
done

ts=${TRADING_SYSTEM_DIR:-../trading_system}
kp=${K_PAPER_DIR:-../k-paper}
ui=${UI_DIR:-../trading-system-ui}
[ -f "$ROOT/$ts/Cargo.toml" ] || [ -f "$ts/Cargo.toml" ] && ok "trading_system Cargo.toml" || bad "trading_system Cargo.toml"
[ -f "$ROOT/$kp/Cargo.toml" ] || [ -f "$kp/Cargo.toml" ] && ok "k-paper Cargo.toml" || bad "k-paper Cargo.toml"
[ -f "$ROOT/$ui/package.json" ] || [ -f "$ui/package.json" ] && ok "ui package.json" || bad "ui package.json"
[ -f "$ROOT/$ui/proto/trading_cli.proto" ] || [ -f "$ui/proto/trading_cli.proto" ] && ok "ui proto" || bad "ui proto"

if sh "$ROOT/scripts/validate-config.sh" "$ROOT/configurations/runner/bot.json" >/dev/null; then
  ok "paper isolation config"
else
  bad "paper isolation config"
fi

if sh "$ROOT/scripts/validate-config.sh" "$ROOT/fixtures/invalid-bot.json" >/dev/null 2>&1; then
  bad "invalid fixture was accepted"
else
  ok "invalid fixture rejected"
fi

if [ -f "$ROOT/.env" ]; then
  ok ".env present"
else
  note "copy .env.example to .env before make build"
fi

compose config >/dev/null && ok "compose.yaml" || bad "compose.yaml"

if [ "$fail" -ne 0 ]; then
  echo "doctor: failed"
  exit 1
fi
echo "doctor: passed"
