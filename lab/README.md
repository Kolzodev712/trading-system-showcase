# Integrated paper laboratory

Self-contained Compose environment for the trading runner, k-paper, and the browser UI.
Paper venue only. Operator ports bind to `127.0.0.1`. Container masquerading is disabled
so runtime services cannot NAT to public exchange hosts.

Sibling checkouts of `trading_system`, `k-paper`, and `trading-system-ui` are required at
build time (see `.env.example`).

## Quick start

```bash
cp .env.example .env
# Edit sibling paths if your Desktop layout differs
make doctor
make build
make demo
```

- UI: http://127.0.0.1:5173
- Runner health: http://127.0.0.1:8080/health
- Trading starts **disabled** until an operator enables it in the UI.
- Sign-in uses the UI development seed (`admin` / `admin`) — change before any shared deploy.

```bash
make verify
make scenario SCENARIO=normal-execution
make stop
make reset   # deletes volumes for this Compose project only
```

## Safety

- `scripts/validate-config.sh` refuses non-Paper venues and live credential markers.
- Do not publish `.env` or operator tokens.

## License

Apache License 2.0 — see the repository root `LICENSE` and `NOTICE`.
