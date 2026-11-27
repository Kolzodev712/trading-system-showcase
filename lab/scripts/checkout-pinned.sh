#!/bin/sh
# Check out pinned component revisions into sibling directories (release mode helper).
# Does not delete unrelated directories. Requires existing clones or creates them.
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

compat="$ROOT/compatibility.json"
test -f "$compat"

python3 - "$compat" "$TRADING_SYSTEM_DIR" "$K_PAPER_DIR" "$UI_DIR" <<'PY'
import json, os, subprocess, sys

compat = json.load(open(sys.argv[1]))
mapping = {
    "trading_system": sys.argv[2],
    "k-paper": sys.argv[3],
    "trading-system-ui": sys.argv[4],
}

def run(cmd, cwd=None):
    print("+", " ".join(cmd))
    subprocess.check_call(cmd, cwd=cwd)

for name, path in mapping.items():
    spec = compat["components"][name]
    ref = spec["ref"]
    repo = spec["repo"]
    if not os.path.isdir(path):
        parent = os.path.dirname(path)
        os.makedirs(parent, exist_ok=True)
        run(["git", "clone", repo, path])
    run(["git", "fetch", "--tags", "origin"], cwd=path)
    run(["git", "checkout", "--detach", ref], cwd=path)
    got = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=path, text=True).strip()
    if got != ref and not got.startswith(ref):
        # allow abbreviated pins
        full = subprocess.check_output(["git", "rev-parse", ref], cwd=path, text=True).strip()
        if got != full:
            raise SystemExit(f"{name}: expected {ref}, got {got}")
    print(f"ok {name} -> {got} at {path}")
PY

echo "checkout-pinned: done"
