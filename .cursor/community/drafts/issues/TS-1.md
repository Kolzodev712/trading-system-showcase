# TS-1 — Minimal ExtraStrategyFactory sample in docs

**Repo:** trading_system  
**Labels:** `documentation`, `good first issue`, `difficulty: easy`  
**URL:** TBD

## Problem

STRATEGY_GUIDE and ARCHITECTURE mention `ExtraStrategyFactory` / `btc_price_ma_app`, but a first-time contributor still lacks a minimal “copy this skeleton” walkthrough.

## Why useful

Enables strategy extension without reading the entire Candidate #2 codebase.

## Relevant files

- `docs/STRATEGY_GUIDE.md`
- `src/btc_price_ma_app/` (reference)
- `libs/strategy_core/`

## Scope

- Short doc section: steps to add a toy factory + composition binary pointers.
- Link existing crates; do **not** add a new plugin system.

## Constraints

- No claim of validated alpha.
- Keep research vs live separation clear.

## Acceptance

- Contributor can follow the doc without private chat.
- Links resolve on GitHub.

## Verification

Doc review + `cargo check -p btc_price_ma_app` still passes (no code required if docs-only).
