# KP-1 — Document REST bootstrap endpoints with curl examples

**Repo:** k-paper  
**Labels:** `documentation`, `good first issue`, `difficulty: easy`, `priority: medium`  
**URL:** TBD

## Problem

New users can run the server but must dig through DEV-GUIDE for basic REST bootstrap (`/exchange_info`, `/balances`, `/open_orders`).

## Why useful

Lowers time-to-first-success for independent k-paper adoption without trading_system.

## Relevant files

- `docs/DEV-GUIDE.md`
- `README.md` (short link)
- `crates/paper-exchange-server/src/lib.rs` (route list)

## Scope

- Add a short “REST quickstart” section with copy-paste `curl` examples against `127.0.0.1:19999`.
- Do not change server behavior.

## Constraints

- No credentials; loopback examples only.
- Do not invent endpoints that do not exist.

## Acceptance

- README or DEV-GUIDE lists exchange_info, balances, open_orders with working examples against `cargo run` / compose.
- Links from README Examples table.

## Verification

```bash
cargo run &
curl -fsS http://127.0.0.1:19999/exchange_info
```
