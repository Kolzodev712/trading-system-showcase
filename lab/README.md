# Integrated paper laboratory

Self-contained Compose environment for the trading runner, k-paper, and the browser UI.
Paper venue only. Operator ports bind to `127.0.0.1`. Container masquerading is disabled
so runtime services cannot NAT to public exchange hosts.

Expected sibling layout (paths in `.env.example` are relative to `lab/`):

```text
workspace/
├── trading_system/
├── k-paper/
├── trading-system-ui/
└── trading-system-showcase/
    └── lab/          ← run make from here
```

Pinned revisions live in `compatibility.json`. `LAB_SOURCE_MODE=release` (default)
stages the pinned `trading_system` Git revision; `dev` stages the working tree.

## Quick start

```bash
cp .env.example .env
# Optional: sh scripts/checkout-pinned.sh
make doctor
make build
make demo
```

- UI: http://127.0.0.1:5173
- Runner health: http://127.0.0.1:8080/health
- Trading starts **disabled** until an operator enables it in the UI.
- Sign-in uses the UI development seed (`admin` / `admin`) — change before any shared deploy.

```bash
make verify                                      # read-only readiness (does not enable trading)
make scenario SCENARIO=normal-execution          # mutating: new order + ACK/fill correlation
make qualify                                     # trading_system just paper gates
make stop
make reset   # deletes volumes for this Compose project only
```

## Safety

- `scripts/validate-config.sh` refuses non-Paper venues and live credential markers.
- Do not publish `.env` or operator tokens.

## Scenarios (evidence strength)

| Scenario | Pass means | Exit 2 |
| --- | --- | --- |
| `normal-execution` | New paper order or trade vs baseline, correlated in runner logs with place ACK or execution | No new correlated order within 180s |
| `partial-fills` | `lab_fill_open` on a runner-ACK’d resting order; REST shows partial fill | No suitable open order |
| `exchange-disconnect` | Trade socket reconnect then connected log | Reconnect not observed |
| `reconciliation` | Bootstrap start **and** completion logs at startup | Missing log lines |
| `risk-rejection` | Risk-block log after `risk-rejection` profile | No block within 180s |
| `operator-control` | Pause/resume accepted; status toggles | gRPC failure |
| `observability` | JSON logs and `/health` | Unstructured logs or unhealthy |
| `lost-ack` | Always blocked here | Recovery drill not automated; faults cleared on exit |

## License

Apache License 2.0 — see the repository root `LICENSE` and `NOTICE`.
