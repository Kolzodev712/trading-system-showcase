# Limitations

- The codebase is not production complete and not mainnet ready.
- - The demonstration is spot level execution against a synthetic book. A linear contract fixture and a separate research composition program exist and are not what this demonstration starts.
- The global trading switch starts disabled. Levels stay idle until an operator enables trading. That is the same control the browser exposes.
- The paper matcher is a test double. Resting orders are not a full central limit order book. Default configuration does not partially fill; a laboratory hook does.
- There is no latency simulator.
- The paper account is stored in memory. Restarting that process drops balances and orders.
- The paper client handles one in-flight place, cancel, and amend. It is not a concurrent-request load generator.
- Reconciliation cannot recover venue state that the paper process has discarded.
- The automated lost-acknowledgement recovery, including a runner restart against a still-living paper process, is a development drill. The short scenario only arms the hook.
- A small Prometheus text endpoint is served by the runner. No Prometheus server is deployed. Distributed tracing is not enabled. The Jaeger exporter is disabled because it is unsafe on the current runtime.
- Optional Redis and Zenoh integrations are not started.
- UI login in the laboratory is a development seed. It is not exchange authorization.
- No performance, capacity, or profitability figure is stated, because this repository does not have a measurement that would support one.
- Screenshots, when present, come from the running UI. This repository does not contain generated mockups of screens the UI does not have.
