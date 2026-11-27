#!/bin/sh
# Fail if the public tree contains likely secrets or local paths.
set -eu
pub=${1:-../trading-system-showcase}
if [ ! -d "$pub" ]; then
  echo "missing public tree: $pub" >&2
  exit 1
fi
patterns='api_key|api_secret|BEGIN PRIVATE|mongodb://|admin / admin|kolzo-dev|/home/|bybit.com|binance.com|JWT_SECRET|lab-root-pass'
if grep -R -n -E -i "$patterns" "$pub" --exclude-dir=.git; then
  echo "public tree matched a disclosure pattern" >&2
  exit 1
fi
echo "public disclosure scan: no matches"
