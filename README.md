# Trading System

A modular trading runtime written in Rust. It ingests market data, keeps exchange and internal state, applies risk checks, and submits orders through an exchange client. A separate paper exchange supplies the market and the order acknowledgements. A browser UI watches and controls the runtime over gRPC.

The implementation is proprietary. This repository is a technical description of that system and of how it is demonstrated. It does not contain the source, container images, or runtime configuration. A live demonstration is available on request.

The system is a working research and laboratory codebase. It is not production complete and it is not mainnet ready. This write-up does not claim a latency budget, a production deployment, or a profitable strategy.

## Problem

An automated trader has to treat market data, order commands, and operator control as different paths, and it has to stay consistent when an acknowledgement is late or a socket drops. Doing that only against a live exchange makes failures expensive and hard to repeat. The laboratory path runs the same runner against a local paper exchange.

## Architecture

The live engines share one process and pass events on in-process channels. The browser does not speak to the exchange. It speaks gRPC-Web to a proxy, which speaks gRPC to the runner. Longer notes are in [system overview](architecture/system-overview.md).

### System

```mermaid
flowchart TB
  operator[Operator browser]
  ui[UI and auth]
  proxy[gRPC-Web proxy]
  runner[Trading runner]
  md[Market-data session]
  ex[Order session]
  paper[Paper exchange]
  mongo[(MongoDB)]

  operator --> ui
  ui --> proxy
  proxy --> runner
  runner --> md
  runner --> ex
  md --> paper
  ex --> paper
  runner --> mongo
  ui --> mongo
```

![System overview](architecture/system-overview.svg)

### Market data

```mermaid
flowchart LR
  book[Paper book] --> session[Market-data session]
  session --> indicators[Indicators]
  indicators --> level[Level price]
```

![Market data](architecture/data-flow.svg)

### Order lifecycle

```mermaid
flowchart LR
  signal[Level signal] --> risk[Risk check]
  risk --> place[Place on socket]
  place --> ack[Acknowledgement]
  ack --> fill[Fill]
  fill --> state[State update]
```

A failed risk check stops the sequence before a place command. The reply is read on the same socket that sent the command.

![Order lifecycle](architecture/order-lifecycle.svg)

### Reconciliation

```mermaid
flowchart LR
  socket[Socket events] --> exchange[Exchange state]
  http[HTTP snapshot] --> exchange
  exchange --> trading[Trading state]
```

Startup and a later timer compare the two states. Restarting the paper process drops its in-memory account, so reconciliation cannot restore a venue state that process has forgotten.

![Reconciliation](architecture/reconciliation-flow.svg)

## The three systems

Each repository is a separate process boundary. The charts below are the internals of those three systems. The laboratory starts the levels path of the runner, the spot paper server, and the browser. Other exchange clients, the on-chain mode, and the linear paper fixture exist in the code and are drawn as present but not started.

### Trading runner

One Rust process. Market data, indicators, the exchange session, and level execution share that process and meet on in-process channels. Operator commands enter through gRPC and do not travel on the market-data channel.

```mermaid
flowchart TB
  subgraph edge [Operator edge]
    grpc[gRPC TradingCliService]
    health[HTTP health, state, and metrics]
    control[Trading control]
  end

  subgraph market [Market-data engine]
    mdclient[Venue market client]
    mdstate[Book and trade cache]
  end

  subgraph indicators [Indicator engine]
    subscriber[Trade subscriber]
    calculator[SMA and EMA calculator]
    bindings[Level price bindings]
  end

  subgraph exchange [Exchange engine]
    client[Venue trade client]
    exstate[Exchange state]
    exrecon[WS versus REST reconciler]
  end

  subgraph trading [Trading engine]
    levels[Levels event loop]
    risk[Risk manager]
    tstate[Trading state]
    trecon[Trading-state reconciler]
    journal[Submission journal and execution ledger]
  end

  assets[Asset engine: instrument rules]
  mongo[(MongoDB configuration)]
  other[Other venue clients and DEX mode, not started in the laboratory]

  mdclient --> mdstate
  mdstate --> subscriber
  mdstate --> levels
  subscriber --> calculator --> bindings --> levels
  levels --> risk --> client
  client --> exstate
  exstate --> exrecon
  exstate --> trecon --> tstate
  tstate --> levels
  assets --> risk
  assets --> levels
  grpc --> control --> levels
  levels --> journal
  mongo --> levels
  mongo --> bindings
  client -.-> other
```

The paper trade client sends each command on one socket and reads the reply on that same socket. It keeps a single in-flight place, cancel, and amend. A missing acknowledgement is looked up by client id instead of placing a second order. Trading starts disabled until an operator enables it. Risk runs before that place call. The asset engine supplies tick size, lot size, and minimum notional from the venue.

### Paper exchange

A separate process. The core has no sockets. The server owns HTTP, WebSocket, the synthetic book, and the one-shot laboratory hooks.

```mermaid
flowchart TB
  subgraph server [Paper server]
    runtime[Startup config and profile]
    market[Synthetic market engine]
    scenario[Optional timed scenario overlay]
    transport[WebSocket transport]
    session[Session and command loop]
    rest[REST snapshots and laboratory hooks]
  end

  subgraph core [Paper core, no network I/O]
    facade[Exchange facade]
    book[Order book]
    match[Fill model]
    orders[Order manager]
    account[Single in-memory account]
    rules[Order validation]
    streams[Market and private event streams]
    faults[One-shot fault hooks]
    linear[Linear contract fixture, not the default spot path]
  end

  runtime --> market
  runtime --> scenario
  market --> facade
  scenario --> facade
  transport --> session --> facade
  rest --> facade
  rest --> faults --> facade
  facade --> book
  facade --> match
  facade --> orders
  facade --> account
  rules --> facade
  match --> book
  match --> account
  facade --> streams --> transport
  linear -.-> account
```

Matching fills a limit when it crosses the current book. Resting user orders are not themselves a multi-participant central book. Default configuration does not slice fills. A partial fill in the demonstration is a laboratory hook on an order the runner already placed. Restarting this process drops the account.

### Trading system UI

A browser client plus a small authentication service. Neither opens a socket to the paper exchange. Monitoring and operator commands go through a gRPC-Web proxy to the runner.

```mermaid
flowchart TB
  subgraph browser [Browser]
    login[Sign in]
    connect[Connect to runner]
    menu[Console]
    spot[Spot monitor]
    futures[Futures monitor]
    dex[DEX monitor]
    store[Client store]
    stream[Monitoring stream]
    levelsPoll[Levels poll]
    controls[Operator controls]
  end

  subgraph panels [Spot panels]
    book[Order book]
    orders[Open orders]
    balances[Balances]
    levelPanel[Levels]
    indPanel[Indicators]
    trades[Recent executions]
  end

  auth[Auth API]
  creds[(Credential store)]
  proxy[gRPC-Web proxy]
  runner[Trading runner gRPC]

  login --> auth --> creds
  connect --> proxy --> runner
  runner --> stream --> store
  store --> menu
  store --> spot
  store --> futures
  store --> dex
  spot --> book
  spot --> orders
  spot --> balances
  spot --> levelPanel
  spot --> indPanel
  spot --> trades
  levelsPoll --> runner
  controls --> proxy
```

The screen follows the runner's instrument type. Spot is the laboratory view. Futures and DEX screens exist for other runner modes and are not what the paper spot demonstration drives. Login is a local demonstration session. It is not an exchange credential. Mutating commands on a non-paper venue also require an operator token injected at the proxy. The paper laboratory leaves that token empty.

## Components

| Component | Role |
| --- | --- |
| Market-data engine | Maintains the public book and trades from the exchange session |
| Exchange engine | Submits orders and tracks acknowledgements, balances, and exchange orders |
| Trading engine | Level execution, risk checks, internal order state, reconciliation |
| Indicator engine | Live SMA and EMA values used by level prices |
| Asset engine | Instrument rules used before an order is sent |
| Runner | Starts those engines, the health endpoint, and the gRPC service |
| Paper exchange | Local matching, balances, and fault hooks. Separate process |
| Browser UI | Monitoring and operator commands. Separate repository |

A separate composition program can host one research model inside the same runner. That program is not required for the level-based laboratory path described here. Research backtests are another pair of tools and do not place live orders.

## What it does

- Connects to a configured exchange client. The laboratory client is the paper exchange.
- Streams order books and trades.
- Prices configured levels from indicators.
- Submits limit orders and applies acknowledgements, fills, and cancels to internal state.
- Reconciles internal state with the exchange view on startup and on a timer.
- Rejects an order that breaks a configured risk limit, including a circuit breaker.
- Exposes health, structured logs, and a gRPC control plane: pause entries, cancel working orders, flatten, resume, and level updates.
- Persists configuration in MongoDB. The levels runner does not start without it.

Other exchange clients exist in the private codebase, including centralized-exchange and on-chain adapters. The public demonstration uses only the paper client. Orders cannot leave the laboratory network.

## Technologies

Rust, Tokio, gRPC, MongoDB, WebSockets, HTTP, Envoy (gRPC-Web), React. Redis and a Zenoh command bus exist as optional integrations and are not part of the laboratory demonstration. The health server exposes a small Prometheus text endpoint (process info, venue mode, broadcast lag). No Prometheus server is deployed. Distributed tracing hooks exist and are left disabled in the demonstration because the Jaeger exporter used by the project is not reliable on the current runtime.

## Engineering problems the code actually takes on

- One order path for more than one exchange, with the paper venue implemented as a client rather than a skipped side effect.
- Fast in-process events for market data and execution, and a separate RPC path for the operator.
- A paper client that correlates each command with the reply on the same socket, and that looks up an order by client id when the reply is missing.
- Reconciliation between the exchange snapshot and the trading state.
- Risk checks that run before an order is sent, with explicit size limits required when execution is enabled.
- A paper exchange that can drop an acknowledgement, disconnect clients, or partially fill an order under a test hook, so those cases can be repeated without a live venue.

Case studies: [engineering decisions](documentation/engineering-decisions.md).

## Reliability

- Readiness fails closed when market data is stale or the exchange snapshot is empty.
- Trade and market-data sessions retry after a disconnect.
- Startup reconciliation compares the exchange view with internal positions and orders.
- The paper account is in memory. Restarting the paper process drops it. That is a laboratory limit, not a recovered-state guarantee.
- Non-paper venues require an operator token on mutating commands. The paper laboratory does not, because it has no path to a real venue.

Details: [reliability](documentation/reliability-and-recovery.md).

## Testing

The private repositories contain unit tests, paper-exchange tests, a process harness that starts the paper exchange with the runner, and browser tests for the UI. The demonstration environment adds a smaller set of runtime checks against the composed processes. Those checks are not a substitute for the crate suites, and this repository does not publish their raw logs.

Details: [testing](documentation/testing-methodology.md).

## Demonstration

A private Compose environment builds the existing binaries, publishes only loopback operator ports, refuses a configuration that is not the local paper exchange, and disables outbound NAT from the container network. Supported scenarios are listed in [demonstration overview](demonstrations/demonstration-overview.md). A recording script is in [video](demonstrations/video.md). No video file is stored here, and none has been published from this repository.

## Limits

See [limitations](documentation/limitations.md). In short: one laboratory account, spot level execution in the demonstration, no latency injector, no durable paper account, and no claim that a backtest or a paper session is evidence of live performance.
