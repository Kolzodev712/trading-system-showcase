#!/bin/sh
# Portable offline bundle. Images and runtime files only. No git history and no source trees.
set -eu
# shellcheck disable=SC1091
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/lib.sh"

out="$ROOT/artifacts/trading-system-demo-bundle"
rm -rf "$out"
mkdir -p "$out/scripts" "$out/configurations" "$out/fixtures"

images="
trading-showcase-k-paper:local
trading-showcase-runner:local
trading-showcase-auth:local
trading-showcase-ui:local
trading-showcase-ops:local
mongo:7.0
envoyproxy/envoy:v1.31.5
"
for image in $images; do
  docker image inspect "$image" >/dev/null
done

echo "exporting images"
# shellcheck disable=SC2086
docker save $images -o "$out/images.tar"

cp "$ROOT/scripts/bundle/compose.yaml" "$out/compose.yaml"
cp -a "$ROOT/configurations/." "$out/configurations/"
cp -a "$ROOT/scenarios/." "$out/fixtures/scenarios/"
cp "$ROOT/scripts/bundle/install.sh" "$out/scripts/install.sh"
cp "$ROOT/scripts/bundle/start.sh" "$out/scripts/start.sh"
cp "$ROOT/scripts/bundle/stop.sh" "$out/scripts/stop.sh"
cp "$ROOT/scripts/bundle/reset.sh" "$out/scripts/reset.sh"
cp "$ROOT/scripts/validate-and-run.sh" "$out/scripts/validate-and-run.sh"
cp "$ROOT/scripts/validate-config.sh" "$out/scripts/validate-config.sh"
cp "$ROOT/scripts/validate-config.py" "$out/scripts/validate-config.py"
mkdir -p "$out/fixtures/proto"
proto_src="$ROOT/artifacts/build/trading-system-ui/proto/trading_cli.proto"
if [ ! -f "$proto_src" ]; then
  proto_src="$UI_DIR/proto/trading_cli.proto"
fi
cp "$proto_src" "$out/fixtures/proto/trading_cli.proto"
cp "$ROOT/scripts/bundle/README.md" "$out/README.md"
cp "$ROOT/compatibility.json" "$out/compatibility.json" 2>/dev/null || true
if [ -f "$ROOT/artifacts/build/STAGED_REVISIONS.json" ]; then
  cp "$ROOT/artifacts/build/STAGED_REVISIONS.json" "$out/STAGED_REVISIONS.json"
fi
chmod +x "$out/scripts/"*.sh

# Fail closed: offline validator must work without the lab git tree.
if ! command -v python3 >/dev/null 2>&1; then
  echo "bundle: python3 required on host to validate the packaged validator" >&2
  exit 1
fi
sh "$out/scripts/validate-config.sh" "$out/configurations/runner/bot.json"
if sh "$out/scripts/validate-config.sh" "$ROOT/fixtures/invalid-bot.json" >/dev/null 2>&1; then
  echo "bundle: packaged validator accepted invalid fixture" >&2
  exit 1
fi

arch=$(uname -m)
os=$(uname -s)
created=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cat > "$out/manifest.json" <<EOF
{
  "name": "trading-system-demo-bundle",
  "created": "$created",
  "cpu_architecture": "$arch",
  "operating_system": "$os",
  "docker": "compose v2",
  "images": [
    "trading-showcase-k-paper:local",
    "trading-showcase-runner:local",
    "trading-showcase-auth:local",
    "trading-showcase-ui:local",
    "trading-showcase-ops:local",
    "mongo:7.0",
    "envoyproxy/envoy:v1.31.5"
  ],
  "notes": "Offline laboratory bundle. Requires Docker; ships validate-config.py for Paper isolation checks."
}
EOF

(
  cd "$out"
  sha256sum images.tar manifest.json compose.yaml README.md > checksums.sha256
  find configurations fixtures scripts -type f -print0 | sort -z | xargs -0 sha256sum >> checksums.sha256
)
echo "bundle: $out"
