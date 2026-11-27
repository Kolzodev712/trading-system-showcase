#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"
BACKEND_PROTO="$TRADING_SYSTEM_DIR/libs/trading_proto/proto/trading_cli.proto"
UI_PROTO="$UI_DIR/proto/trading_cli.proto"
diff -q "$BACKEND_PROTO" "$UI_PROTO"
echo "ok protocol definitions match ($TRADING_SYSTEM_DIR ↔ $UI_DIR)"
