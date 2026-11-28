#!/usr/bin/env bash
# PREPARE ONLY — do not run until the owner approves.
# Applies repository descriptions and topics for discoverability.
set -euo pipefail

gh repo edit Kolzodev712/trading_system \
  --description "Modular Rust trading infrastructure with exchange adapters, risk management, order execution, reconciliation and strategy research." \
  --add-topic rust \
  --add-topic algorithmic-trading \
  --add-topic trading-engine \
  --add-topic quantitative-finance \
  --add-topic tokio \
  --add-topic market-data \
  --add-topic backtesting \
  --add-topic trading-infrastructure

gh repo edit Kolzodev712/k-paper \
  --description "Standalone exchange simulator with synthetic markets, HTTP/WebSocket APIs and fault injection for trading-system testing." \
  --add-topic rust \
  --add-topic paper-trading \
  --add-topic exchange-simulator \
  --add-topic fault-injection \
  --add-topic integration-testing \
  --add-topic websocket \
  --add-topic market-simulation \
  --add-topic algorithmic-trading

gh repo edit Kolzodev712/trading-system-ui \
  --description "React and TypeScript operator console for monitoring, configuring and controlling automated trading systems through gRPC-Web." \
  --add-topic react \
  --add-topic typescript \
  --add-topic grpc-web \
  --add-topic trading-dashboard \
  --add-topic algorithmic-trading \
  --add-topic monitoring

gh repo edit Kolzodev712/trading-system-showcase \
  --description "Integrated open-source Rust trading laboratory with reproducible deployment, architecture documentation and failure-testing scenarios." \
  --add-topic rust \
  --add-topic algorithmic-trading \
  --add-topic docker-compose \
  --add-topic systems-engineering \
  --add-topic paper-trading \
  --add-topic fault-injection \
  --add-topic open-source

echo "Optional: pin repositories on the GitHub profile UI (gh has no stable profile-pin API):"
echo "  trading_system, k-paper, trading-system-ui, trading-system-showcase, company-ai-poc, cursor-hub"
