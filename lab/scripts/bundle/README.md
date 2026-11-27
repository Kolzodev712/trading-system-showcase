# Offline demonstration bundle

Private artifact. Load it on a machine that already has Docker and the same CPU architecture recorded in `manifest.json`.

```bash
sha256sum -c checksums.sha256
scripts/install.sh
scripts/start.sh
```

`compose.yaml` sets `pull_policy: never`. Startup does not download images or source.

`scripts/reset.sh` removes only the volumes created by this compose project, then starts it again.

The operator UI is published on `127.0.0.1:5173`. The runner health endpoint is published on `127.0.0.1:8080`. Other services stay on an internal Docker network.
