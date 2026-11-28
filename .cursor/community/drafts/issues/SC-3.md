# SC-3 — Design: stronger lost-ack demonstration

**Repo:** trading-system-showcase  
**Labels:** `needs-design`, `difficulty: hard`, `priority: low`  
**URL:** TBD

## Problem

`lost-ack` scenario remains BLOCKED; arming the fault is not recovery evidence.

## Why useful

Shows a core reliability story of the ecosystem.

## Scope

- Design how to reuse trading_system workflow harness for suppress-ack → ambiguous submit → venue lookup → recovery without duplicate execution.
- Keep BLOCKED until design + bounded implementation approved.

## Constraints

- Prefer reuse over new frameworks.
- Must reset lab faults on exit.
- Do not claim recovery from hook arming alone.

## Acceptance (design)

- Written plan with effort estimate and acceptance tests.
- Maintainer approval before coding.
