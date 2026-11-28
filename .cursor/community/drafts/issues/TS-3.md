# TS-3 — Exchange-adapter contribution checklist

**Repo:** trading_system  
**Labels:** `documentation`, `good first issue`, `difficulty: easy`  
**URL:** TBD

## Problem

Adapter contributions are high-risk; newcomers lack a checklist covering venue modes, credentials handling, and Paper/Demo boundaries.

## Why useful

Reduces unsafe PRs and clarifies maintainer expectations.

## Relevant files

- `docs/EXCHANGE_CAPABILITY_MATRIX.md`
- `docs/VENUE_MODES.md`
- `src/exchange_engine/`, `src/market_data_engine/`
- `CONTRIBUTING.md` (link)

## Scope

- New short doc or CONTRIBUTING section: checklist only.
- No new adapters.

## Constraints

- Emphasize no live secrets in PRs; Paper-first verification.

## Acceptance

- Checklist merged and linked from CONTRIBUTING / capability matrix.

## Verification

Doc review.
