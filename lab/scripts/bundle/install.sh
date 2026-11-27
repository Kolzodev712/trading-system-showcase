#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
docker load -i images.tar
echo "images loaded. Start with scripts/start.sh"
