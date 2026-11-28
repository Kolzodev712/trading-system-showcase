# KP-5 — Proposal: optional message latency injection

**Repo:** k-paper  
**Labels:** `enhancement`, `needs-design`, `difficulty: hard`, `priority: low`  
**URL:** TBD

## Problem

Lab faults cover drops/partials; delayed ACK/market messages are a common real failure mode not configurable today.

## Why useful

Lets trading_system recovery paths be tested without real venues.

## Scope (proposal only until design accepted)

- Design doc: where delay applies (ACK vs market stream), config surface, defaults off.
- No implementation in the first PR unless design is approved.

## Constraints

- Must not be on by default.
- Must not claim Bybit parity.
- Financial safety: delayed ACK semantics must be explicit.

## Acceptance (design phase)

- Written design with alternatives, risks, and verification plan.
- Maintainer approval before code.

## Verification

N/A until implementation issue is spun out.
