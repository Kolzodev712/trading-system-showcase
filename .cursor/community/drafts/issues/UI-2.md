# UI-2 — Operator-control Playwright coverage

**Repo:** trading-system-ui  
**Labels:** `testing`, `difficulty: medium`  
**URL:** TBD

## Problem

Unit tests cover much operator logic; browser coverage for pause/resume/enable paths is thinner than the control-plane importance warrants.

## Why useful

Catches wiring regressions between UI and Envoy/runner in Paper lab.

## Relevant files

- `npm run test:paper-e2e`
- Operator control components
- Showcase lab optional

## Scope

- Add or extend Playwright cases for one clear operator flow against a documented stack.
- Skip/block cleanly if stack unavailable.

## Constraints

- Paper only; no live venues.
- Do not embed secrets.

## Acceptance

- Documented how to run; CI-less local command in CONTRIBUTING/PR template.

## Verification

`npm run test:paper-e2e` with lab or documented local stack.
