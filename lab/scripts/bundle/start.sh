#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
docker compose -f compose.yaml up -d --no-build --pull never
echo "UI: http://127.0.0.1:5173"
echo "Health: http://127.0.0.1:8080/health"
