#!/bin/sh
# Fail closed unless the bot file is an unambiguous local Paper configuration.
# Requires python3 and validate-config.py beside this script (host, runner image, or offline bundle).
set -eu
HERE=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
BOT=${1:?bot.json path required}
PY="$HERE/validate-config.py"

if ! command -v python3 >/dev/null 2>&1; then
  echo "refusing bot config: python3 is required for structured validation" >&2
  exit 1
fi
if [ ! -f "$PY" ]; then
  echo "refusing bot config: missing $PY (offline bundles must ship validate-config.py)" >&2
  exit 1
fi
exec python3 "$PY" "$BOT"
