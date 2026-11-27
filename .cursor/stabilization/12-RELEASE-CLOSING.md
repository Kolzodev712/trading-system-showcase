# Release-closing evidence (2026-11-27)

## Fixes in this pass

1. Python3 in runner + ops images; offline bundle ships `validate-config.py` and self-tests the packaged validator.
2. `stage-sources.sh` pins **all three** components; compose builds only from `artifacts/build/*`.
3. Verify refuses down stack, treats proto3 omitted `enabled` as disabled, requires real outbound probe client, checks staged pins.
4. k-paper `external_http_client` Rust example (no websocat) — PASS against standalone.
5. Fresh workspace doctor PASS (`/tmp/oss-fresh-*` clones + pinned checkout).
6. Lab `make build` + `make demo` PASS after instruments.yaml tick-config fix.
7. Scenarios (this machine, after demo):

| Scenario | Result |
|----------|--------|
| normal-execution | PASS |
| operator-control | PASS |
| observability | PASS |
| partial-fills | PASS |
| exchange-disconnect | PASS |
| risk-rejection | PASS |
| reconciliation | PASS (completion log only) |
| lost-ack | BLOCKED (retained) |

8. Docs: showcase README relative links OK; screenshot exception for `screenshots/*.png`.
9. Owner gates still required before tag.
10. Proposed tag set: `v0.1.1` on all four remotes after owner OK.

## Component tests

| Check | Result |
|-------|--------|
| UI `npm test` | PASS 82 |
| k-paper `cargo test --all` | PASS |
| trading_system `just test-fast` | re-run after artifact cleanup |
| `just test-paper` / `make qualify` | NOT_RUN in this pass (time); infrastructure ready |

## Pins (compatibility.json)

- trading_system `28b7765…`
- k-paper `bd67158…`
- trading-system-ui `3bd5ca2…`
