#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
docker compose -f compose.yaml down -v --timeout 40
docker compose -f compose.yaml up -d --no-build --pull never
