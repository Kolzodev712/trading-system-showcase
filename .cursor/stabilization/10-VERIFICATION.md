# Stabilization 10 — Verification evidence

**Date:** 2026-11-27  
**Mode:** Local public-checkout verification (not a fresh empty workspace clone).  
**Publish:** Code push authorized by owner; no new version tags in this step unless listed below.

## Component revisions (pre-push working trees)

Recorded after commits in Stabilization 11; see `lab/compatibility.json` post-push.

## Executed checks

| Area | Command / check | Result |
|------|-----------------|--------|
| trading_system | `cargo check -p runner` | PASS |
| trading_system | `just test-fast` / paper layers | NOT_RUN (time; use `make qualify`) |
| k-paper | `cargo test -p paper-exchange-core` | PASS (37) |
| k-paper | `cargo build --examples` | PASS |
| k-paper | standalone Docker build | NOT_RUN |
| UI | `npm test` | PASS (82) |
| UI | `scripts/check-proto-sync.sh` | PASS |
| UI | `npm run build` | NOT_RUN |
| showcase | `lab/scripts/doctor.sh` | PASS |
| showcase | structured validate-config + negative fixtures | PASS |
| showcase | `make build` / `make verify` / scenarios | NOT_RUN (container image build deferred) |
| showcase | offline bundle | NOT_RUN |
| research | research unit suite | NOT_RUN (covered by `just test-fast` when run) |

## Known limitations (unchanged)

- Not production/mainnet complete; research candidates ≠ validated alpha.
- Historical gitleaks 18 findings: **OPEN_OWNER** rotation confirmation (`docs/PUBLICATION_SECURITY_FINDINGS.md`).
- Dataset redistribution: **OPEN_REVIEW**.
- Lost-ack scenario remains **BLOCKED**.
- Isolation claim: single outbound HTTP probe + compose loopback ports — not full network proof.
- Envoy host networking retained in standalone UI docker stack (documented).

## Owner gates still open

1. Credential rotation confirmation (F01).
2. Dataset redistribution posture (F18).
