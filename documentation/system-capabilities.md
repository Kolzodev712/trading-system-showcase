# System capabilities

These are capabilities present in the implementation that the laboratory demonstration is built to exercise. A capability is listed only when the corresponding code exists. Runtime confirmation is a separate step, done in the private environment, and is not restated here as a benchmark.

## Market data

The paper exchange publishes a synthetic order book and trades. The runner's market-data session consumes that stream and retries after the socket closes. Indicators (SMA and EMA) are updated from that stream. Level prices bind to an indicator plus an offset.

## Orders

Levels mode can place, amend, and cancel limit orders through the paper client. The client sends the command on the trade socket and reads the reply there. Fills update balances and order state. The paper matcher fills a limit when it crosses the current book. It is not a multi-user central limit order book: resting user orders are not themselves the book other participants trade against.

## State

The runner keeps exchange state and trading state. Startup reconciliation and a timer compare them. Client order ids are stable enough for a lookup when an acknowledgement is missing. The paper client allows one in-flight place, one in-flight cancel, and one in-flight amend.

## Risk

Before an order is sent, the trading engine checks a circuit breaker, daily-loss figures when a ledger is present, order count, notional, quantity, balance, and position caps. Exchange mode refuses to start unless a size or count limit is configured. A rejected level is logged and is not submitted.

## Operator

The gRPC service reports monitoring data and accepts pause, cancel-working, flatten-and-pause, and resume, plus level create, update, delete, and enable. The browser shows the spot monitor for this laboratory path: books, orders, trades, balances, levels, and those controls.

## Fault hooks on the paper exchange

The paper server exposes test-only HTTP hooks: disconnect clients, suppress the next place acknowledgement, reject the next place, duplicate a fill, stale the book, fail the open-order query, and partially fill a resting order. The default fill configuration does not itself slice orders into partial fills. A partial fill in the demonstration is that hook, applied to an order the runner has already placed.

## Not in the demonstration

Latency injection is not implemented. The paper account does not survive a paper-process restart. Prometheus is not scraped. Jaeger is switched off. The on-chain engine and the separate research composition binary are not started.
