# Ecosystem roadmap

Single concise roadmap for the public trading ecosystem. Implementation detail lives in component repositories.

**Not production / mainnet ready. Research candidates are not validated alpha.** No delivery dates are promised.

## 1. Available functionality (v0.1.1)

| Area | Where |
|------|--------|
| Modular Rust runner, risk, journaling, reconciliation | [trading_system](https://github.com/Kolzodev712/trading_system) |
| Research framework + public candidates | trading_system `research/` |
| Standalone paper exchange + fault hooks | [k-paper](https://github.com/Kolzodev712/k-paper) |
| Operator console (gRPC-Web) | [trading-system-ui](https://github.com/Kolzodev712/trading-system-ui) |
| Integrated Paper lab + scenarios | [lab/](lab/) in this repo |

## 2. Open contribution opportunities

Published issues (accepted scopes):

| Issue | Labels |
|-------|--------|
| [k-paper#1 — REST onboarding discoverability](https://github.com/Kolzodev712/k-paper/issues/1) | good first issue |
| [k-paper#2 — Python WebSocket trade client](https://github.com/Kolzodev712/k-paper/issues/2) | help wanted |
| [k-paper#3 — Wide-spread / thin book preset](https://github.com/Kolzodev712/k-paper/issues/3) | enhancement |
| [trading_system#6 — ExtraStrategyFactory walkthrough](https://github.com/Kolzodev712/trading_system/issues/6) | good first issue |
| [trading_system#7 — Adapter contribution checklist](https://github.com/Kolzodev712/trading_system/issues/7) | good first issue |
| [trading_system#8 — Research CLI onboarding](https://github.com/Kolzodev712/trading_system/issues/8) | documentation |
| [trading-system-ui#2 — Operator-control accessibility](https://github.com/Kolzodev712/trading-system-ui/issues/2) | accessibility |
| [showcase#1 — Lab troubleshooting guide](https://github.com/Kolzodev712/trading-system-showcase/issues/1) | good first issue |

Hub discussion: [Welcome to the trading ecosystem](https://github.com/Kolzodev712/trading-system-showcase/discussions/2).

## 3. Maintainer-led improvements

- Broader Linux distribution install verification for `lab/` (after SC-2 scope is evidence-based)
- Coordinated pin updates in `lab/compatibility.json` for releases
- Triage and review of the published contribution issues above

## 4. Experimental design proposals (not approved implementation)

These require architectural discussion before coding:

- Configurable message latency in k-paper (draft KP-5)
- Stronger lost-acknowledgement demonstration in the lab (draft SC-3; currently BLOCKED)

## 5. Demand-driven future development

- Additional exchange integrations only with clear demand and Paper/Demo qualification plan
- Hosted services and commercial packaging (out of open-source scope unless separately commissioned)

## Unpublished backlog (not yet actionable as issues)

Kept local under `.cursor/community/drafts/issues/` until scopes are concrete:

- KP-3 — matching/accounting test gaps (needs exact missing cases)
- TS-2 — indicator edge-case tests (needs specific uncovered cases)
- UI-1 — unavailable vs empty fields (needs panel inventory)
- UI-2 — Playwright flows (needs specific missing flows)
- SC-2 — OS/Docker matrix (needs verified platform evidence)

## How to engage

1. Start with [lab/](lab/) or a single component README.
2. Open issues with templates; security via each repo’s Security Advisories / `SECURITY.md`.
3. Prefer small PRs; see each `CONTRIBUTING.md` and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
