# UI-3 — Accessibility pass on operator controls

**Repo:** trading-system-ui  
**Labels:** `enhancement`, `difficulty: medium`  
**URL:** TBD  
**Note:** showcase already has an `accessibility` label; create/use consistently on UI repo when labels are applied.

## Problem

Operator controls are dense; keyboard and label semantics may be incomplete.

## Why useful

Safer operation under stress and broader usability.

## Relevant files

- `src/components/layout/OperatorControls.tsx` and related dialogs

## Scope

- Keyboard focus, button names, confirmation dialogs for destructive actions.
- Targeted tests where practical.

## Constraints

- Do not restyle the entire app.

## Acceptance

- Checklist of a11y fixes; tests or manual verification notes in PR.

## Verification

`npm test` + short manual keyboard walkthrough noted in PR.
