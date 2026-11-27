#!/bin/sh
# Copy the runner sources into this repository's build area so the image build
# is not subject to trading_system/.dockerignore, which excludes *secret*.
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

src="$ROOT/${TRADING_SYSTEM_DIR:-../trading_system}"
dest="$ROOT/artifacts/build/trading_system"
mkdir -p "$dest"
rsync -a --delete \
  --exclude /target \
  --exclude /runtime-data \
  --exclude /data \
  --exclude /.git \
  --exclude /artifacts \
  --exclude /python \
  --exclude /docs \
  --exclude /.cursor \
  --exclude /architecture \
  --exclude /audit \
  --exclude /proposals \
  --exclude /observability \
  --exclude /deploy \
  --exclude '*.log' \
  --exclude /.dockerignore \
  "$src/" "$dest/"
rm -f "$dest/.dockerignore"
test -f "$dest/libs/trading_core/src/secret.rs"
test -e "$dest/src/indicator_engine/src/data.rs" -o -d "$dest/src/indicator_engine/src/data"
echo "staged runner sources at $dest"
