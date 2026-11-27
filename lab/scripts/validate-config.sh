#!/bin/sh
# Fail closed unless the bot file is an unambiguous local Paper configuration.
# Delegates to structured JSON validation (allowlist).
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
exec python3 "$ROOT/scripts/validate-config.py" "${1:?bot.json path required}"
