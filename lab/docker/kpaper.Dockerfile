# syntax=docker/dockerfile:1
# Build context is this demo repository. k-paper sources come from the named
# additional context `kpaper` so this image does not vendor proprietary source.
FROM rust:1.98.1-bookworm AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libssl-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY --from=kpaper / /src
RUN cargo build --release --bin k-paper

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10001 paper
COPY --from=build /src/target/release/k-paper /usr/local/bin/k-paper
USER paper
EXPOSE 19999
HEALTHCHECK --interval=5s --timeout=3s --start-period=10s --retries=12 \
  CMD curl -fsS http://127.0.0.1:19999/exchange_info >/dev/null
ENTRYPOINT ["/usr/local/bin/k-paper"]
