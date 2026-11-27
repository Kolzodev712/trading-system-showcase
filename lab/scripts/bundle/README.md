# Offline demonstration bundle

Public laboratory offline artifact. Load it on a machine that already has Docker and the same CPU architecture recorded in `manifest.json`. Requires `python3` on the host for `scripts/validate-config.sh` (ships `validate-config.py`).

```bash
sha256sum -c checksums.sha256
scripts/install.sh
# Optional: scripts/validate-config.sh configurations/runner/bot.json
scripts/start.sh
```

`compose.yaml` sets `pull_policy: never`. Startup does not download images or source.

`scripts/reset.sh` removes only the volumes created by this compose project, then starts it again.

The operator UI is published on `127.0.0.1:5173`. The runner health endpoint is published on `127.0.0.1:8080`. Other services stay on an internal Docker network. Laboratory fault routes are enabled via `PAPER_LAB_FAULTS=1`.
