# Phase 0 — Community readiness assessment

**Date:** 2026-11-28  
**Method:** Local trees + `gh` read-only (REST/GraphQL where authenticated).

## Repository metadata (current)

| Repo | Description | Topics | Discussions | Issues open | Releases | `.github/` templates |
|------|-------------|--------|-------------|-------------|----------|----------------------|
| trading_system | **empty** | **none** | no | 0 | v0.1.1 | **absent** |
| k-paper | "Paper exchange integration" (weak) | **none** | no | 0 | v0.1.1 | **absent** |
| trading-system-ui | **empty** | **none** | no | 0 | v0.1.1 | **absent** |
| trading-system-showcase | **empty** | **none** | no | 0 | v0.1.1 | **absent** |

Default labels only (`bug`, `enhancement`, `good first issue`, …). Showcase also has `accessibility`. Missing: testing, needs-design, needs-reproduction, difficulty/*, priority/*.

## Docs present

| Artifact | TS | k-paper | UI | showcase |
|----------|----|---------|----|----------|
| CONTRIBUTING.md | yes (stale research-export claims) | minimal | minimal | minimal |
| SECURITY.md | yes | yes | yes | yes |
| CODE_OF_CONDUCT | no | no | no | no |
| ROADMAP | no | no | no | no |
| Issue/PR templates | no | no | no | no |

## README snapshot

- **trading_system:** Solid boundaries; broken GitHub nav via `../trading-system-showcase` relative links.
- **k-paper:** Strong independent-use framing already.
- **UI:** Features-first; needs clearer lab path + contributing + limitations sections.
- **showcase:** Good entry structure (screenshot, quickstart); strengthen contribution / services / absolute component links.

## Contact / security

SECURITY.md present in all four; no public maintainer email verified in this pass beyond license NOTICE.

## Inconsistencies to fix locally

1. CONTRIBUTING claims research excluded from public trees (superseded).
2. Relative cross-repo README links.
3. Empty/weak GitHub descriptions and topics (commands prepared, not applied).
4. No issue/PR templates; thin contribution guides.
5. No ecosystem ROADMAP; Discussions not enabled (recommend showcase only).
