# Stabilization 0 — Baseline assessment

**Date:** 2026-11-27  
**Method:** Local inspection of public checkouts + private demo peek for migration gaps only.

## Cross-repository dependencies

```text
trading-system-showcase/lab  → builds/runs trading_system, k-paper, trading-system-ui
trading-system-ui/proto      → should match trading_system/libs/trading_proto/proto
trading_system               → talks to k-paper over Paper WS in lab configs
showcase-demo (private)      → historical lab source; public lab already under showcase/lab/
```

Expected sibling layout for public install:

```text
workspace/
├── trading_system/
├── k-paper/
├── trading-system-ui/
└── trading-system-showcase/lab/   # paths must be ../../…
```

## Build / deploy entry points (summary)

| Repo | Entry points observed |
|------|------------------------|
| trading_system | Justfile (`test-fast`, `test-5r-graph`, `test-paper`, `test-paper-negative`, `test-paper-ui`, `ci-local`); root Dockerfile* (status TBD Inc 3); `Dockerfile.paper-bin`; lab builds via staged sources |
| k-paper | `cargo` workspace; `Dockerfile`; `docker-compose.yml` port `19999:19999` |
| trading-system-ui | npm scripts; `docker/docker-compose.yml` + Envoy; auth `server/` |
| showcase | `lab/Makefile` → doctor/build/demo/verify/bundle/scenario/reset/stop |

## Protocol

| Location | GetRiskSnapshot / RiskSnapshot / halt fields / working_orders_unfiltered |
|----------|--------------------------------------------------------------------------|
| `trading_system/.../trading_cli.proto` | present |
| `trading-system-ui/proto/trading_cli.proto` | **absent** (CONFIRMED drift) |

## Documentation ownership (current, messy)

| Topic | Where it lives today | Intended owner (Inc 9) |
|-------|----------------------|-------------------------|
| Runner/risk/recovery/research | trading_system + duplicated showcase docs | trading_system |
| Simulator/faults | k-paper + showcase | k-paper |
| UI/auth | UI + showcase | trading-system-ui |
| Integrated lab / demos | showcase | showcase |

## Known limitations (already documented elsewhere)

- Not production/mainnet complete
- No GitHub Actions
- Lost-ack demo historically BLOCKED/incomplete
- Historical secrets in trading_system git history (rotation owner-owned)
- Research candidates must not be sold as validated alpha

## Finding dispositions

See [TRACKER.md](TRACKER.md) finding register. Proceed with all `CONFIRMED` items; investigate `UNKNOWN` before code changes in their owning increment.
