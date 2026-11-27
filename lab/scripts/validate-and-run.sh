#!/bin/sh
set -eu

ROOT=/opt/showcase/configurations
PROFILE=${SHOWCASE_PROFILE:-normal}
BOT_SRC=$ROOT/runner/bot.json
LEVELS=$ROOT/profiles/$PROFILE/levels.json

/opt/showcase/scripts/validate-config.sh "$BOT_SRC"

if [ ! -f "$LEVELS" ]; then
  echo "unknown demonstration profile: $PROFILE" >&2
  exit 1
fi

if [ ! -f "$ROOT/runner/indicators.json" ]; then
  echo "missing indicators.json" >&2
  exit 1
fi

rm -rf /app/config
mkdir -p /app/config /app/runtime-data
cp "$BOT_SRC" /app/config/bot.json
cp "$ROOT/runner/indicators.json" /app/config/indicators.json
cp "$LEVELS" /app/config/levels.json

echo "starting runner profile=$PROFILE exchange=Paper"
exec /usr/local/bin/runner \
  --mode levels \
  --config /app/config/bot.json \
  --levels-config /app/config/levels.json
