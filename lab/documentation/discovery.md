# Discovery

Inspection date: 2026-11-26. No existing repository was modified. Classifications below are from reading the implementation. Runtime results are recorded separately in `verification-report.md` after the demonstration environment is executed. Nothing here is inferred to fill a gap.

## Trading system

Workspace binary of interest for this showcase: `runner` (`src/runner`), levels mode. The process is one container, not one container per engine.

| Piece | Responsibility | Status |
| --- | --- | --- |
| `libs/trading_core` | Shared types, gRPC messages, execution mode | IMPLEMENTED_UNVERIFIED |
| `libs/trading_networking` | Optional Zenoh command/event plane | IMPLEMENTED_UNVERIFIED |
| `libs/trading_trace` | Tracing helpers, optional Jaeger/Prometheus exporters | IMPLEMENTED_UNVERIFIED |
| `libs/strategy_core` | Pure model. Not linked by `runner` | IMPLEMENTED_UNVERIFIED |
| `src/exchange_engine` | Private exchange session, order commands, exchange state | IMPLEMENTED_UNVERIFIED |
| `src/market_data_engine` | Public market-data session | IMPLEMENTED_UNVERIFIED |
| `src/trading_engine` | Levels, risk, trading state, reconciliation | IMPLEMENTED_UNVERIFIED |
| `src/indicator_engine` | SMA, EMA, composite indicators | IMPLEMENTED_UNVERIFIED |
| `src/asset_engine` | Instrument rules. Paper uses k-paper REST | IMPLEMENTED_UNVERIFIED |
| `src/gateway` | `TradingCliService` gRPC | IMPLEMENTED_UNVERIFIED |
| `src/live_config` | Mongo-backed config updates | IMPLEMENTED_UNVERIFIED |
| `src/btc_price_ma_app` | Separate composition binary. Not used by this showcase | IMPLEMENTED_UNVERIFIED |
| `src/dex_engine` | DeepBook/Sui path. Not used by this showcase | IMPLEMENTED_UNVERIFIED |
| `cli` | Rust TUI gRPC client | IMPLEMENTED_UNVERIFIED |
| `research/*` | Historical research. Not in the live runner | IMPLEMENTED_UNVERIFIED |

Entry point: `runner --mode levels --config <bot.json> --levels-config <levels.json>`. Indicator file path is hardcoded to `config/indicators.json` relative to the process working directory (`src/runner/src/platform/init.rs`).

Runtime dependencies observed: Tokio, MongoDB when `mongo.enabled` is true (required for levels), optional Redis (disabled in the paper sample), optional Zenoh (`ZENOH_ENABLED`), optional Jaeger. The paper sample sets Redis disabled. Levels mode refuses to start if MongoDB is disabled.

Configuration used by the local paper smoke (documented in `docs/LOCAL_DEV_GUIDE.md`, files under `sample_config/k-paper/`): exchange `Paper`, `paper_exchange_url` `ws://127.0.0.1:19999/ws/trade`, spot BTC/USDT and ETH/USDT, reconciliation enabled, Mongo enabled.

Exchange clients present in code: Binance, Bybit, Paper, DeepBook. This showcase allows only Paper.

Market data: k-paper client connects to `/ws/market`, derived from the trade URL, and loops with a 2 second pause after an error (`market_data_engine` k-paper client).

Order path: trading engine submits through the exchange engine. The Paper client uses `/ws/trade` for commands and replies on that socket. REST is used for balances, open orders, trades, exchange info, and client-id lookup. The Paper client documents one in-flight place, cancel, and amend.

State: exchange state manager plus trading state. Startup calls `reconcile`. Exchange-level bootstrap logs `Starting bootstrap reconciliation`. Intervals come from bot config. The sample default is 180000 ms. The demonstration config uses 20000 ms so the same code path is easier to observe. That is a configuration change in this repository only.

Risk: `RiskLimits` must be explicit in exchange mode. Pre-trade checks cover a circuit breaker, daily loss, order count, notional, quantity, balance, and position caps. A blocked level logs `blocked by risk check`.

Networking inside the runner: broadcast channels between engines. Operator commands use gRPC, not those channels. Zenoh is off unless `ZENOH_ENABLED=1`.

Observability: tracing logs, `GET /health` (503 until CEX readiness: market data freshness and a non-empty balance or order snapshot), `GET /metrics` only when an exporter is installed (otherwise 404), `GET /state` and `GET /orders`. Jaeger is disabled in this demonstration because `launch.rs` notes that the Jaeger exporter panics on the current Tokio runtime. `TRACE_JAEGER_DISABLED=1` is the existing lab switch.

Tests present in the tree: crate unit tests, `tests/workflow_harness` (spawns k-paper and the runner), integration helpers. This discovery did not re-run `cargo test`.

Container files: `Dockerfile` is stale relative to the workspace. It copies a subset of crates and would not build `runner` as the workspace exists today (runner depends on `gateway`, `dex_engine`, `trading_networking`, `trading_trace`). `Dockerfile.paper-bin` is only a Debian runtime for a host-built binary. `docker-compose.report.yml` runs two paper venues plus levels and strategies, mounting host binaries. This showcase does not use that compose file. A new Dockerfile lives in the demonstration repository.

## K-paper

| Capability | Evidence | Status |
| --- | --- | --- |
| HTTP and WebSocket server | `paper-exchange-server`, routes in `lib.rs` | IMPLEMENTED_UNVERIFIED |
| `/ws/market`, `/ws/trade` | same | IMPLEMENTED_UNVERIFIED |
| REST balances, open orders, positions, trades, exchange info, order by client id | `rest.rs` | IMPLEMENTED_UNVERIFIED |
| Matching against the current book | core matching. User orders do not form a multi-participant CLOB | IMPLEMENTED_UNVERIFIED |
| Synthetic market engine | `market` section and `PAPER_EXCHANGE_PROFILE=dev` | IMPLEMENTED_UNVERIFIED |
| Static and timed scenarios | `PAPER_EXCHANGE_SCENARIO`, presets in the developer guide | IMPLEMENTED_UNVERIFIED |
| Partial fill as a one-shot lab hook | `POST /test/partial_next_fill`, `POST /test/lab_fill_open` | IMPLEMENTED_UNVERIFIED |
| Default matcher partial fills | `fill_model.partial_fills: false` in `config/instruments.yaml`. Developer guide: partial fills are not fully exercised in v1 | MISSING as default matcher behavior |
| Latency simulation | no latency parameter found | MISSING |
| Disconnect, dropped ack, reject, duplicate fill, stale book, failed open-orders query | `/test/*` routes | IMPLEMENTED_UNVERIFIED |
| Spot accounting | default `instruments.yaml` | IMPLEMENTED_UNVERIFIED |
| USDT-linear BTCUSDT fixture | `config/linear-btcusdt.yaml` | IMPLEMENTED_UNVERIFIED, not selected by this showcase |
| Durable account across process restart | in-memory account, documented as lost on restart | MISSING |

The demonstration uses the spot book, profile `dev`, and seed `42`. It does not point the runner at a live exchange.

## Trading system UI

React/Vite client. Browser calls `/api` for login and `/grpc` for gRPC-Web. Envoy translates gRPC-Web to the runner on port 50051. The UI does not open a socket to k-paper or to Binance/Bybit.

Auth is an Express server with MongoDB credentials. The development seed creates `admin` / `admin` when the credentials collection is empty. That password stays in the private interview guide.

Views in the client: welcome, spot monitor, futures monitor, DEX monitor, levels, strategies, orders, trades, balances, positions, order books, indicators, operator pause/cancel/flatten/resume. The paper spot levels runner drives the spot monitor. Futures and DEX screens are not the path this showcase starts.

The UI repository compose file runs Envoy with `network_mode: host` and a cluster address of `127.0.0.1:50051`. That does not fit an isolated bridge network. The demonstration ships its own Envoy config aimed at `runner:50051`. The UI repository is not modified.

## How the three repositories run together

```text
Browser :5173
  → nginx (static UI, /api, /grpc)
      → auth :3001 → MongoDB trading_ui
      → Envoy :8081 → runner gRPC :50051
                         runner
                         ├─ /ws/trade  → k-paper :19999
                         ├─ /ws/market → k-paper :19999
                         └─ MongoDB trading_system
```

MongoDB is required by the levels runner. Redis, Zenoh, Prometheus, and Jaeger are not started. Envoy is required because the browser speaks gRPC-Web.

## Demonstration scenarios that the code can support

| Scenario | Basis | Expected showcase status until executed |
| --- | --- | --- |
| Normal lifecycle | levels mode places against the paper book after indicators warm up | new order vs baseline + runner ACK/execution correlation; exit 2 if none |
| Partial fill | lab hook on a runner-ACK’d resting order; REST partial state | not the default matcher |
| Disconnect | `POST /test/disconnect_clients`, reconnect log, trade socket connected again | exit 2 if reconnect incomplete |
| Reconciliation | bootstrap start and completion log lines | planted drift is not claimed |
| Lost acknowledgement | `POST /test/suppress_place_ack` then `reset_lab_faults` | hook only; recovery-by-restart is not automated or claimed |
| Risk rejection | tighter `max_order_qty` profile | log line `blocked by risk check` |
| Operator control | gRPC `PauseEntries` / `Resume` | Paper does not require an operator token |
| Observability | JSON logs and `/health` | `/metrics` is 404 without an exporter |

## Missing or blocked

- Latency injection: MISSING.
- Default partial-fill matcher: MISSING (`partial_fills: false`).
- Paper account survival across k-paper restart: MISSING.
- Automated lost-ack recovery in this showcase: BLOCKED on a runner restart procedure that this environment does not automate. The hook itself exists.
- Candidate #2 composition app and the linear fixture: implemented elsewhere, not wired here, so this showcase does not demonstrate them.
- Full crate test suite execution: not run during discovery.

## Required changes to the existing repositories

None for the spot levels path. The demonstration image builds `runner` with a Dockerfile in this repository because the existing `trading_system/Dockerfile` does not copy the current crate graph. Updating that Dockerfile would be a convenience, not a requirement.

## Safety boundary

The runner starts only after `scripts/validate-config.sh` accepts the bot file. The file must say `"exchange": "Paper"`, must use `ws://k-paper:19999/ws/trade`, must use the local Mongo hostname, must keep Redis disabled, and must not contain known live-venue hosts or credential field names. The Compose network disables IP masquerade, so containers cannot NAT to public exchange hosts. Operator ports bind to `127.0.0.1`. A fully internal Docker network was tried first; this engine does not publish host ports on an internal network, which blocked the operator UI.
