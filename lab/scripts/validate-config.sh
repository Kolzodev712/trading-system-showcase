#!/bin/sh
# Fail closed unless the bot file is an unambiguous local Paper configuration.
set -eu

BOT=${1:?bot.json path required}

if [ ! -f "$BOT" ]; then
  echo "missing bot config: $BOT" >&2
  exit 1
fi

if grep -E -i 'binance|bybit|okx|coinbase|kraken|fapi|stream\.binance|api\.bybit|mainnet|api_key|api_secret|secret_key' "$BOT" >/dev/null; then
  echo "refusing bot config: real-venue host, credential field, or ambiguous venue marker" >&2
  exit 1
fi

if ! grep -q '"exchange"[[:space:]]*:[[:space:]]*"Paper"' "$BOT"; then
  echo "refusing bot config: exchange must be Paper" >&2
  exit 1
fi

if ! grep -q 'ws://k-paper:19999/ws/trade' "$BOT"; then
  echo "refusing bot config: paper_exchange_url must be ws://k-paper:19999/ws/trade" >&2
  exit 1
fi

if grep -E 'wss://|https://' "$BOT" >/dev/null; then
  echo "refusing bot config: external https/wss URL" >&2
  exit 1
fi

if ! grep -q 'mongodb://mongodb:27017' "$BOT"; then
  echo "refusing bot config: mongo must be the local demonstration database" >&2
  exit 1
fi

if ! grep -A4 '"redis"' "$BOT" | grep -q '"enabled"[[:space:]]*:[[:space:]]*false'; then
  echo "refusing bot config: redis must be disabled" >&2
  exit 1
fi

echo "paper isolation config ok: $BOT"
