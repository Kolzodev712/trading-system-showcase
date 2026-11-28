# TS-2 — Indicator engine unit-test gaps

**Repo:** trading_system  
**Labels:** `testing`, `difficulty: medium`  
**URL:** TBD

## Problem

Indicator calculations power level pricing; coverage is uneven across SMA/EMA edge cases (empty windows, warm-up).

## Why useful

Prevents silent pricing mistakes when extending indicators.

## Relevant files

- `src/indicator_engine/`

## Scope

- Inventory existing tests; add missing unit tests for warm-up and empty input behavior.
- No API redesign.

## Constraints

- Deterministic tests only.

## Acceptance

- New tests document expected behavior; `cargo test -p indicator_engine` passes.

## Verification

```bash
cargo test -p indicator_engine
```
