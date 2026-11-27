#!/bin/sh
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

fail=0
note() { printf '  %s\n' "$1"; }
bad() { printf '  FAIL %s\n' "$1"; fail=1; }
ok() { printf '  ok   %s\n' "$1"; }

echo "doctor: demonstration prerequisites"
echo "  ROOT=$ROOT"
echo "  LAB_SOURCE_MODE=$LAB_SOURCE_MODE"

command -v docker >/dev/null 2>&1 && ok "docker" || bad "docker is not installed"
docker info >/dev/null 2>&1 && ok "docker daemon" || bad "docker daemon is not reachable"
docker compose version >/dev/null 2>&1 && ok "docker compose" || bad "docker compose is not installed"
command -v git >/dev/null 2>&1 && ok "git" || bad "git is not installed"
command -v python3 >/dev/null 2>&1 && ok "python3" || bad "python3 is not installed"
[ -f "$ROOT/scripts/validate-config.py" ] && ok "validate-config.py" || bad "validate-config.py missing"

for pair in \
  "TRADING_SYSTEM_DIR:$TRADING_SYSTEM_DIR" \
  "K_PAPER_DIR:$K_PAPER_DIR" \
  "UI_DIR:$UI_DIR"
do
  name=${pair%%:*}
  path=${pair#*:}
  if [ -z "$path" ]; then
    bad "$name is unset"
    continue
  fi
  if [ -d "$path" ]; then
    ok "$name ($path)"
  else
    bad "$name does not exist ($path)"
  fi
done

[ -f "$TRADING_SYSTEM_DIR/Cargo.toml" ] && ok "trading_system Cargo.toml" || bad "trading_system Cargo.toml"
[ -f "$K_PAPER_DIR/Cargo.toml" ] && ok "k-paper Cargo.toml" || bad "k-paper Cargo.toml"
[ -f "$UI_DIR/package.json" ] && ok "ui package.json" || bad "ui package.json"
[ -f "$UI_DIR/proto/trading_cli.proto" ] && ok "ui proto" || bad "ui proto"
[ -f "$ROOT/compatibility.json" ] && ok "compatibility.json" || bad "compatibility.json"

if [ "$LAB_SOURCE_MODE" = "release" ] && [ -f "$ROOT/compatibility.json" ]; then
  python3 - "$ROOT/compatibility.json" "$TRADING_SYSTEM_DIR" "$K_PAPER_DIR" "$UI_DIR" <<'PY' || fail=1
import json, subprocess, sys
compat = json.load(open(sys.argv[1]))
mapping = {
    "trading_system": sys.argv[2],
    "k-paper": sys.argv[3],
    "trading-system-ui": sys.argv[4],
}
rc = 0
for name, path in mapping.items():
    ref = compat["components"][name]["ref"]
    try:
        subprocess.check_call(
            ["git", "-C", path, "cat-file", "-e", f"{ref}^{{commit}}"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        print(f"  ok   pinned {name} revision present ({ref})")
    except subprocess.CalledProcessError:
        print(f"  FAIL pinned {name} revision missing ({ref}); run scripts/checkout-pinned.sh or LAB_SOURCE_MODE=dev")
        rc = 1
sys.exit(rc)
PY
fi

if sh "$ROOT/scripts/validate-config.sh" "$ROOT/configurations/runner/bot.json" >/dev/null; then
  ok "paper isolation config"
else
  bad "paper isolation config"
fi

neg_fail=0
for fix in invalid-bot.json invalid-redis-enabled.json invalid-external-mongo.json invalid-api-key-field.json; do
  if sh "$ROOT/scripts/validate-config.sh" "$ROOT/fixtures/$fix" >/dev/null 2>&1; then
    bad "invalid fixture accepted ($fix)"
    neg_fail=1
  fi
done
[ "$neg_fail" -eq 0 ] && ok "invalid fixtures rejected"

if [ -f "$ROOT/.env" ]; then
  ok ".env present"
else
  note "copy .env.example to .env before make build"
fi

# Compose must reference staged build contexts (not live sibling defaults) for release builds.
if grep -q 'artifacts/build/k-paper' "$ROOT/compose.yaml" \
  && grep -q 'artifacts/build/trading-system-ui' "$ROOT/compose.yaml" \
  && grep -q 'artifacts/build/trading_system' "$ROOT/compose.yaml"; then
  ok "compose uses staged build contexts"
else
  bad "compose must use ./artifacts/build/* contexts for all components"
fi

compose config >/dev/null && ok "compose.yaml" || bad "compose.yaml"

if [ "$fail" -ne 0 ]; then
  echo "doctor: failed"
  exit 1
fi
echo "doctor: passed"
