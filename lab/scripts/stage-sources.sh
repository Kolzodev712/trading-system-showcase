#!/bin/sh
# Stage pinned (release) or working-tree (dev) sources for laboratory image builds.
# Stages trading_system, k-paper, and trading-system-ui under artifacts/build/.
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

compat="$ROOT/compatibility.json"
build_root="$ROOT/artifacts/build"

case "$build_root" in
  "$ROOT"/artifacts/build) ;;
  *)
    echo "refusing unexpected build root: $build_root" >&2
    exit 1
    ;;
esac

mkdir -p "$build_root"

pinned_ref() {
  component=$1
  python3 - "$compat" "$component" <<'PY'
import json,sys
print(json.load(open(sys.argv[1]))["components"][sys.argv[2]]["ref"])
PY
}

stage_git_archive() {
  name=$1
  src=$2
  dest=$3
  ref=$4
  if [ ! -d "$src/.git" ] && [ ! -f "$src/.git" ]; then
    echo "release mode requires a git checkout at $src" >&2
    exit 1
  fi
  if ! git -C "$src" cat-file -e "$ref^{commit}" 2>/dev/null; then
    echo "pinned revision $ref not found in $src; fetch or LAB_SOURCE_MODE=dev" >&2
    exit 1
  fi
  rm -rf "$dest"
  mkdir -p "$dest"
  echo "staging $name @$ref (release)"
  git -C "$src" archive --format=tar "$ref" | tar -x -C "$dest"
  printf '%s\n' "$ref" >"$dest/.showcase-source-revision"
  printf '%s\n' release >"$dest/.showcase-source-mode"
}

stage_dev_tree() {
  name=$1
  src=$2
  dest=$3
  echo "staging $name working tree from $src (dev — not reproducible)"
  rm -rf "$dest"
  mkdir -p "$dest"
  rsync -a \
    --exclude /.git \
    --exclude /target \
    --exclude /node_modules \
    --exclude /dist \
    --exclude /runtime-data \
    --exclude /data \
    --exclude /artifacts \
    --exclude /config \
    --exclude /secrets \
    --exclude /trading_keys \
    --exclude '**/.env' \
    --exclude '**/*.pem' \
    --exclude '*.log' \
    --exclude /.cursor \
    "$src/" "$dest/"
  rev=$(git -C "$src" rev-parse HEAD 2>/dev/null || echo "unknown")
  dirty=$(git -C "$src" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  printf '%s\n' "${rev}+dirty${dirty}" >"$dest/.showcase-source-revision"
  printf '%s\n' dev >"$dest/.showcase-source-mode"
}

require_compat() {
  if [ ! -f "$compat" ]; then
    echo "missing compatibility manifest: $compat" >&2
    exit 1
  fi
}

case "$LAB_SOURCE_MODE" in
  release)
    require_compat
    stage_git_archive trading_system "$TRADING_SYSTEM_DIR" "$build_root/trading_system" "$(pinned_ref trading_system)"
    stage_git_archive k-paper "$K_PAPER_DIR" "$build_root/k-paper" "$(pinned_ref k-paper)"
    stage_git_archive trading-system-ui "$UI_DIR" "$build_root/trading-system-ui" "$(pinned_ref trading-system-ui)"
    ;;
  dev)
    stage_dev_tree trading_system "$TRADING_SYSTEM_DIR" "$build_root/trading_system"
    stage_dev_tree k-paper "$K_PAPER_DIR" "$build_root/k-paper"
    stage_dev_tree trading-system-ui "$UI_DIR" "$build_root/trading-system-ui"
    ;;
  *)
    echo "LAB_SOURCE_MODE must be release or dev (got: $LAB_SOURCE_MODE)" >&2
    exit 1
    ;;
esac

test -f "$build_root/trading_system/libs/trading_core/src/secret.rs"
test -e "$build_root/trading_system/src/indicator_engine/src/data.rs" \
  -o -d "$build_root/trading_system/src/indicator_engine/src/data"
test -f "$build_root/k-paper/Cargo.toml"
test -f "$build_root/trading-system-ui/package.json"
test -f "$build_root/trading-system-ui/proto/trading_cli.proto"

# Record the staged set for doctor/verify.
python3 - "$compat" "$build_root" "$LAB_SOURCE_MODE" <<'PY'
import json, pathlib, sys
compat = json.load(open(sys.argv[1])) if pathlib.Path(sys.argv[1]).exists() else {}
root = pathlib.Path(sys.argv[2])
mode = sys.argv[3]
out = {"mode": mode, "components": {}}
for name, dirname in [
    ("trading_system", "trading_system"),
    ("k-paper", "k-paper"),
    ("trading-system-ui", "trading-system-ui"),
]:
    rev = (root / dirname / ".showcase-source-revision").read_text().strip()
    pinned = (compat.get("components") or {}).get(name, {}).get("ref")
    out["components"][name] = {"staged": rev, "pinned": pinned}
pathlib.Path(root / "STAGED_REVISIONS.json").write_text(json.dumps(out, indent=2) + "\n")
print("wrote", root / "STAGED_REVISIONS.json")
PY

echo "staged sources under $build_root (mode=$LAB_SOURCE_MODE)"
