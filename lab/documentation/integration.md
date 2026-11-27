# Integration

The demonstration runs the existing spot levels smoke path from `trading_system/docs/LOCAL_DEV_GUIDE.md`, inside Compose.

## Images

| Image | Built from | Runtime contents |
| --- | --- | --- |
| `trading-showcase-k-paper:local` | `k-paper` via additional build context | `k-paper` binary, curl, CA certificates |
| `trading-showcase-runner:local` | `trading_system` via additional build context | `runner` binary, curl, CA certificates, libssl |
| `trading-showcase-auth:local` | `trading-system-ui` server, compiled | Node and production npm dependencies |
| `trading-showcase-ui:local` | Vite `dist/` | nginx and static files |
| `trading-showcase-ops:local` | alpine | curl, jq, grpcurl |
| `mongo:7.0` | upstream | pulled at `make build` |
| `envoyproxy/envoy:v1.31.5` | upstream | pulled at `make build` |

`make build` needs network access for base images, crates.io, and the Mysten Labs git dependency already declared by `trading_system`. `make demo` uses `--pull never` and an internal network.

## Why a new runner Dockerfile

`trading_system/Dockerfile` predates the current workspace members. Replacing it would be an edit to a private repository, which this work does not do. The demonstration Dockerfile copies the workspace through its existing `.dockerignore` and deletes the `test_runner` manifest entry because that source file is excluded by the same dockerignore.

## Config mount

`configurations/runner/bot.json` is the paper sample with three substitutions:

- paper URL `ws://k-paper:19999/ws/trade`
- Mongo URL `mongodb://mongodb:27017`
- reconciliation intervals 20 seconds

Journal files are written under `/app/runtime-data`, which is a volume owned by this Compose project. `make reset` deletes that volume and the Mongo volume of this project only (`docker compose down -v` for project `trading-showcase`).

The paper sample account starts with a large base-asset balance. The runner counts that balance toward the position limit, so the sample level cap rejects every order (`100 > 0.1`). This demonstration starts base balances at zero and raises the level quantity enough to clear the paper minimum notional. That is configuration in this repository. The sample files in `trading_system` are unchanged.

## Startup order

Mongo and k-paper become healthy, then the runner. Envoy starts after the runner health check passes. The UI starts after auth is healthy and Envoy has started. The runner health check is `GET /health` with curl `-f`, so a 503 readiness failure keeps the stack from being called ready.

## What is intentionally absent

Redis, Zenoh, Prometheus, Jaeger, Binance, Bybit, and DeepBook. No production credentials are mounted. The operator token file is empty. On Paper the runner does not require that token.
