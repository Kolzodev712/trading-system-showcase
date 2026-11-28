# KP-3 — Expand matching edge-case unit tests

**Repo:** k-paper  
**Labels:** `testing`, `difficulty: medium`, `priority: medium`  
**URL:** TBD

## Problem

Core matching and account updates have tests, but several edge cases (partial fills, reject paths, locked balances) are unevenly covered relative to lab fault hooks.

## Why useful

Protects independent users and the showcase lab when changing fill models.

## Relevant files

- `crates/paper-exchange-core/src/`
- `crates/paper-exchange-core` tests
- Lab hooks in `paper-exchange-server` (reference only)

## Scope

- Add focused unit tests for 2–4 documented edge cases found by reading core + DEV-GUIDE.
- No new features.

## Constraints

- Do not weaken existing invariants.
- Prefer core tests over flaky integration.

## Acceptance

- New tests fail if the edge case regresses; `cargo test -p paper-exchange-core` passes.

## Verification

```bash
cargo test -p paper-exchange-core -- --test-threads=1
```
