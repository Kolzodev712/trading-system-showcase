# syntax=docker/dockerfile:1
# Supported laboratory runner image. Root trading_system Dockerfiles are obsolete;
# this build uses a staged/pinned trading_system context (see lab/scripts/stage-sources.sh).
FROM rust:1.98.1-bookworm AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libssl-dev ca-certificates protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY --from=trading_system / /src
# Fail closed if required sources are missing — do not rewrite Cargo manifests.
RUN test -f libs/trading_core/src/secret.rs \
  && test -f src/runner/Cargo.toml \
  && (test -f src/runner/src/bin/test_runner.rs || test -f src/runner/src/bin/runner.rs || true)
RUN cargo build --locked --release -p runner --bin runner

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
