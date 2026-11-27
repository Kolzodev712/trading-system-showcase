#!/bin/sh
# Run one demonstration scenario. Exits 0 on observed evidence, 2 when the
# capability cannot be shown in this run, 1 on unexpected failure.
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

name=${1:-}
script="$ROOT/scenarios/${name}.sh"
if [ -z "$name" ] || [ ! -f "$script" ]; then
  echo "usage: make scenario SCENARIO=<name>" >&2
  echo "available:" >&2
  find "$ROOT/scenarios" -maxdepth 1 -name '*.sh' -printf '  %f\n' | sed 's/\.sh$//' >&2
  exit 1
fi
# shellcheck disable=SC1090
. "$script"
