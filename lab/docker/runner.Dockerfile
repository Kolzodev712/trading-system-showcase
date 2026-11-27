# syntax=docker/dockerfile:1
# Additional context `trading_system` is the private runner repository.
# The existing trading_system Dockerfile does not match the current workspace
# (it omits gateway, dex_engine, and trading_networking), so the demonstration
# image is defined here and the private repository is left unchanged.
FROM rust:1.98.1-bookworm AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libssl-dev ca-certificates protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY --from=trading_system / /src
# The upstream dockerignore drops *secret* and test_runner.rs. The staged
# context includes them. If a file is still absent, drop only that bin entry.
RUN python3 - <<'PY'
from pathlib import Path
src = Path("src/runner/src/bin/test_runner.rs")
if src.exists():
    raise SystemExit(0)
p = Path("src/runner/Cargo.toml")
text = p.read_text()
start = text.find('name = "test_runner"')
if start == -1:
    raise SystemExit(0)
head = text.rfind("[[bin]]", 0, start)
end = text.find("[[bin]]", start)
if end == -1:
    end = len(text)
p.write_text(text[:head] + text[end:])
PY
RUN cargo build --release -p runner --bin runner

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libssl3 curl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 1000 appuser \
    && mkdir -p /app/config /app/runtime-data \
    && chown -R appuser:appuser /app
COPY --from=build /src/target/release/runner /usr/local/bin/runner
WORKDIR /app
USER appuser
EXPOSE 8080 50051
HEALTHCHECK --interval=10s --timeout=5s --start-period=90s --retries=18 \
  CMD curl -fsS http://127.0.0.1:8080/health >/dev/null
ENTRYPOINT ["/bin/sh", "/usr/local/bin/validate-and-run.sh"]
