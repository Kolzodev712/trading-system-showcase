# SC-1 — Troubleshooting guide for common lab failures

**Repo:** trading-system-showcase  
**Labels:** `documentation`, `good first issue`, `difficulty: easy`  
**URL:** TBD

## Problem

`make doctor` / `make demo` failures (Docker, pins, k-paper config, ports) are rediscovered by each new user.

## Why useful

Primary ecosystem onboarding path.

## Relevant files

- `lab/README.md`
- `lab/scripts/doctor.sh`
- Known issues from stabilization notes

## Scope

- Add `lab/TROUBLESHOOTING.md` (or section) covering: daemon down, missing pins, instruments tick config, port conflicts, verify requiring running stack.
- Link from lab README.

## Constraints

- Paper-only; no live venue advice.

## Acceptance

- At least five concrete failure → fix pairs.

## Verification

Doc review against actual script messages.
