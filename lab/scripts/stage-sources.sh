#!/bin/sh
# Stage runner sources for the laboratory image build.
#
# LAB_SOURCE_MODE=release (default): extract the pinned trading_system Git revision
#   from the local checkout (must contain that commit). No untracked files.
# LAB_SOURCE_MODE=dev: copy the working tree (for local modifications). Still
#   excludes runtime secrets/artifacts; keeps .dockerignore (do not strip it).
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

dest="$ROOT/artifacts/build/trading_system"
compat="$ROOT/compatibility.json"
src="$TRADING_SYSTEM_DIR"

# Safety: never delete paths outside the lab artifacts tree.
case "$dest" in
  "$ROOT"/artifacts/build/*) ;;
  *)
    echo "refusing to stage outside $ROOT/artifacts/build: $dest" >&2
    exit 1
    ;;
esac

rm -rf "$dest"
mkdir -p "$dest"

write_revision_stamp() {
  rev=$1
  mode=$2
  printf '%s\n' "$rev" >"$dest/.showcase-source-revision"
  printf '%s\n' "$mode" >"$dest/.showcase-source-mode"
}

stage_release() {
  if [ ! -d "$src/.git" ] && [ ! -f "$src/.git" ]; then
    echo "release mode requires a git checkout at $src" >&2
    exit 1
  fi
  if [ ! -f "$compat" ]; then
    echo "missing compatibility manifest: $compat" >&2
    exit 1
  fi
  ref=$(python3 - "$compat" <<'PY'
import json,sys
print(json.load(open(sys.argv[1]))["components"]["trading_system"]["ref"])
PY
)
  if ! git -C "$src" cat-file -e "$ref^{commit}" 2>/dev/null; then
    echo "pinned revision $ref not found in $src; fetch or switch LAB_SOURCE_MODE=dev" >&2
    exit 1
  fi
  echo "staging trading_system @$ref (release)"
  git -C "$src" archive --format=tar "$ref" | tar -x -C "$dest"
  write_revision_stamp "$ref" release
}

stage_dev() {
  echo "staging trading_system working tree from $src (dev — not reproducible)"
  # Do not use --delete against unrelated trees; dest was cleared above.
  rsync -a \
    --exclude /.git \
    --exclude /target \
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
  write_revision_stamp "${rev}+dirty${dirty}" dev
}

case "$LAB_SOURCE_MODE" in
  release) stage_release ;;
  dev) stage_dev ;;
  *)
    echo "LAB_SOURCE_MODE must be release or dev (got: $LAB_SOURCE_MODE)" >&2
    exit 1
    ;;
esac

test -f "$dest/libs/trading_core/src/secret.rs"
test -e "$dest/src/indicator_engine/src/data.rs" -o -d "$dest/src/indicator_engine/src/data"
echo "staged runner sources at $dest (mode=$LAB_SOURCE_MODE)"
