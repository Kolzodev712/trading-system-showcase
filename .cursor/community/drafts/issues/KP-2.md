# KP-2 — Add Python WebSocket trade client example

**Repo:** k-paper  
**Labels:** `enhancement`, `help wanted`, `difficulty: medium`, `priority: medium`  
**URL:** TBD  
**Depends on:** KP-1 helpful but not required

## Problem

Rust `external_http_client` exists; Python users still lack a first-class example for `/ws/trade`.

## Why useful

Widens independent adoption beyond Rust.

## Relevant files

- `examples/` (new script)
- `docs/DEV-GUIDE.md`
- `docs/API-*.md` if present

## Scope

- Single Python 3 script using stdlib or a well-known WS library documented in README.
- Connect, place one limit order, print execution/ack, query REST state.
- Fail loudly on errors.

## Constraints

- No trading_system dependency.
- Do not enable lab faults by default.

## Acceptance

- Documented command line; exits non-zero on failure.
- Works against local `cargo run` server.

## Verification

Run script against local k-paper; show order in `/open_orders` or fill evidence.
