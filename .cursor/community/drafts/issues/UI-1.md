# UI-1 — Distinguish unavailable vs empty monitoring fields

**Repo:** trading-system-ui  
**Labels:** `enhancement`, `difficulty: medium`  
**URL:** TBD

## Problem

Backend exposes source availability (`orderbook_source`, etc.). Some panels may still read as “zero” when data is unavailable.

## Why useful

Prevents operators from trusting missing data as verified empty books/PnL.

## Relevant files

- `src/components/layout/VenueModeBanner.tsx` (partial)
- Monitoring panels / transforms
- `proto/trading_cli.proto`

## Scope

- Audit panels that show quantities/PnL; show unavailable/stale affordances where proto provides signals.
- Add/extend unit tests.

## Constraints

- Do not invent a risk engine in the UI.
- Preserve proto field numbers.

## Acceptance

- Tests for unavailable presentation; no regression of live happy path.

## Verification

```bash
npm test
npm run build
```
