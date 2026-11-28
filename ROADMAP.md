# Ecosystem roadmap

Single concise roadmap for the public trading ecosystem. Implementation detail lives in component repositories.

**Not production / mainnet ready. Research candidates are not validated alpha.**

## Available now (v0.1.1)

| Area | Where |
|------|--------|
| Modular Rust runner, risk, journaling, reconciliation | [trading_system](https://github.com/Kolzodev712/trading_system) |
| Research framework + public candidates | trading_system `research/` |
| Standalone paper exchange + fault hooks | [k-paper](https://github.com/Kolzodev712/k-paper) |
| Operator console (gRPC-Web) | [trading-system-ui](https://github.com/Kolzodev712/trading-system-ui) |
| Integrated Paper lab + scenarios | [lab/](lab/) in this repo |

## Open contribution opportunities

Draft issues are prepared under `.cursor/community/drafts/issues/` (publish after owner approval). Themes:

- k-paper scenarios, tests, and client examples
- trading_system docs, indicators tests, strategy composition samples
- UI unavailable/stale presentation and accessibility
- Showcase troubleshooting and onboarding docs

## Planned improvements (maintainer-led or discussed)

- Stronger lost-acknowledgement demonstration (currently BLOCKED in lab)
- Broader Linux distribution install verification for `lab/`
- Demand-driven venue adapters (not speculative builds)

## Experimental / demand-driven

- Configurable message latency and historical market replay in k-paper
- Additional exchange integrations
- Hosted services and commercial packaging (out of open-source scope unless separately commissioned)

## How to engage

1. Start with [lab/](lab/) or a single component README.
2. Open issues with templates; security via each repo’s `SECURITY.md`.
3. Prefer small PRs; see each `CONTRIBUTING.md`.
