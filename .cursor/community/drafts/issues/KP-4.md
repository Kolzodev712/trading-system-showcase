# KP-4 — Scenario preset for wide spread / thin book

**Repo:** k-paper  
**Labels:** `enhancement`, `difficulty: medium`, `priority: low`  
**URL:** TBD

## Problem

Existing scenario presets emphasize happy-path books; reliability drills often need wide spreads / thin depth.

## Why useful

Supports integration tests without custom YAML for every consumer.

## Relevant files

- Scenario preset loading in `paper-exchange-server` / DEV-GUIDE `PAPER_EXCHANGE_SCENARIO`
- `config/` examples

## Scope

- Add one documented preset (or YAML fixture) with wide spread and few levels.
- Document how to enable it.

## Constraints

- Tick-aligned prices (`step_ticks` / defaults); no absolute `step`/`spread_half`.
- Keep default profile unchanged.

## Acceptance

- Documented env/YAML switch; observable book shape via REST/WS.

## Verification

Start server with preset; dump top of book; compare to docs.
