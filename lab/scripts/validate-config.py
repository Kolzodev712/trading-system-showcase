#!/usr/bin/env python3
"""Structured laboratory bot.json validation (allowlist). Fail closed."""
from __future__ import annotations

import json
import sys
from typing import Any
from urllib.parse import urlparse

ALLOWED_EXCHANGES = {"Paper"}
ALLOWED_PAPER_WS = {"ws://k-paper:19999/ws/trade"}
ALLOWED_MONGO_PREFIXES = ("mongodb://mongodb:", "mongodb://127.0.0.1:", "mongodb://localhost:")
FORBIDDEN_CREDENTIAL_KEYS = {
    "api_key",
    "api_secret",
    "secret_key",
    "private_key",
    "access_key",
    "passphrase",
}


def fail(msg: str) -> None:
    print(f"refusing bot config: {msg}", file=sys.stderr)
    raise SystemExit(1)


def walk(obj: Any, path: str = "") -> None:
    if isinstance(obj, dict):
        for k, v in obj.items():
            key = str(k)
            lower = key.lower()
            if lower in FORBIDDEN_CREDENTIAL_KEYS or lower.endswith("_api_key"):
                fail(f"credential field present at {path}/{key}" if path else f"credential field present: {key}")
            walk(v, f"{path}/{key}" if path else key)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            walk(v, f"{path}[{i}]")


def require_dict(obj: Any, name: str) -> dict:
    if not isinstance(obj, dict):
        fail(f"{name} must be an object")
    return obj


def main() -> None:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <bot.json>", file=sys.stderr)
        raise SystemExit(2)
    path = sys.argv[1]
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        fail(f"unreadable or invalid JSON ({e})")

    data = require_dict(data, "root")
    walk(data)

    ee = require_dict(data.get("exchange_engine"), "exchange_engine")
    exchange = ee.get("exchange")
    if exchange not in ALLOWED_EXCHANGES:
        fail(f"exchange must be one of {sorted(ALLOWED_EXCHANGES)} (got {exchange!r})")

    cfg = require_dict(ee.get("config"), "exchange_engine.config")
    paper_url = cfg.get("paper_exchange_url")
    if paper_url not in ALLOWED_PAPER_WS:
        fail("paper_exchange_url must be ws://k-paper:19999/ws/trade")

    parsed = urlparse(str(paper_url))
    if parsed.scheme != "ws":
        fail("paper_exchange_url must use ws:// (not wss)")

    # Reject any absolute URL fields that leave the laboratory.
    def check_urls(obj: Any, p: str = "") -> None:
        if isinstance(obj, dict):
            for k, v in obj.items():
                check_urls(v, f"{p}.{k}" if p else str(k))
        elif isinstance(obj, list):
            for i, v in enumerate(obj):
                check_urls(v, f"{p}[{i}]")
        elif isinstance(obj, str):
            if obj.startswith("https://") or obj.startswith("wss://"):
                fail(f"external https/wss URL at {p}: {obj}")
            if "://" in obj and not obj.startswith(("ws://", "mongodb://", "redis://", "http://mongodb", "http://k-paper", "http://runner", "http://envoy", "http://ui", "http://127.0.0.1", "http://localhost")):
                # Allow relative paths; flag other absolute network schemes.
                scheme = obj.split("://", 1)[0].lower()
                if scheme in {"http", "https", "ws", "wss", "grpc", "grpcs"}:
                    fail(f"unexpected network URL at {p}: {obj}")

    check_urls(data)

    mongo = require_dict(data.get("mongo"), "mongo")
    if mongo.get("enabled") is False:
        fail("mongo must be enabled for the laboratory runner")
    conn = str(mongo.get("connection_string") or "")
    if not any(conn.startswith(p) for p in ALLOWED_MONGO_PREFIXES):
        fail("mongo connection_string must target the laboratory mongodb service or loopback")

    redis = require_dict(data.get("redis"), "redis")
    if redis.get("enabled") is not False:
        fail("redis must be disabled")

    print(f"paper isolation config ok: {path}")


if __name__ == "__main__":
    main()
