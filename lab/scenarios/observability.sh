#!/bin/sh
set -eu
# shellcheck disable=SC1091
ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
. "$ROOT/scripts/lib.sh"

echo "scenario observability"
logs=$(compose logs runner --tail 20 --no-color 2>/dev/null || true)
echo "$logs" | grep -q '"level"' || echo "$logs" | head -n 1 | grep -q '{' || {
  echo "FAIL runner logs are not JSON" >&2
  echo "$logs" >&2
  exit 1
}
echo "ok   structured runner logs"
health=$(curl -fsS http://127.0.0.1:8080/health)
echo "$health" | grep -q '"status":"healthy"' || { echo "FAIL health $health" >&2; exit 1; }
echo "ok   health endpoint"
metrics=$(ops curl -s -o /tmp/metrics-body -w '%{http_code}' http://runner:8080/metrics || true)
echo "info /metrics HTTP $metrics (404 means no Prometheus exporter is installed in this process)"
echo "scenario observability: passed"
