# Trading runner

One Rust process. Live CEX engines share that process and pass events on in-process broadcast channels. The laboratory demonstration starts `--mode levels` against the paper client. Other venue clients, strategy composition, and DEX mode exist in the tree and are marked below as not started in that demonstration.

```mermaid
flowchart TB
  subgraph edge [Operator and health edge]
    gateway[gateway: TradingCliService]
    pause[PauseEntries / CancelWorking / FlattenAndPause / Resume]
    levelsrpc[Level CRUD and ToggleLevel]
    mon[GetMonitoringData and StreamMonitoringData]
    status[GetTradingStatus / SetTradingEnabled]
    health[HTTP /health /state /orders /metrics]
  end

  subgraph runner [runner orchestrator]
    launch[CLI: mode, bot, levels]
    init[Mongo, assets, engines]
    control[TradingControl]
    live[Live config service]
  end

  subgraph md [market_data_engine]
    mdadapter[Venue market client]
    mdcache[Orderbook and trade cache]
    mdchan[Broadcast to subscribers]
  end

  subgraph ind [indicator_engine]
    indsub[Trade subscriber]
    calc[SMA / EMA calculator]
    bind[Level price bindings]
  end

  subgraph ex [exchange_engine]
    tradeclient[Venue trade client]
    driv[Session driver and reconnect]
    exstate[ExchangeStateManager]
    exrecon[WS versus REST reconciler]
  end

  subgraph te [trading_engine]
    loop[Levels event loop]
    risk[Risk manager and circuit breaker]
    tstate[TradingState]
    trecon[Trading reconciler]
    journal[Submission journal]
    ledger[Execution ledger]
  end

  assets[asset_engine: tick, lot, min notional]
  mongo[(MongoDB)]
  paper[Paper venue]
  others[Binance / Bybit / DeepBook clients, not started in the laboratory]

  launch --> init --> control
  init --> md
  init --> ind
  init --> ex
  init --> te
  init --> assets
  init --> live
  init --> gateway
  init --> health

  gateway --> pause
  gateway --> levelsrpc
  gateway --> mon
  gateway --> status
  pause --> control
  status --> control
  control --> loop
  levelsrpc --> loop
  live --> mongo
  bind --> mongo

  mdadapter --> mdcache --> mdchan
  mdchan --> indsub
  mdchan --> loop
  indsub --> calc --> bind --> loop

  loop --> risk
  risk --> assets
  risk --> tradeclient
  tradeclient --> driv --> exstate
  exstate --> exrecon
  exstate --> trecon --> tstate
  tstate --> loop
  loop --> journal
  loop --> ledger

  mdadapter --> paper
  tradeclient --> paper
  tradeclient -.-> others
```

## Boundaries that matter

| Path | What it carries |
| --- | --- |
| Market-data channel | Books and public trades inside the process |
| Trade WebSocket | Places, cancels, amends, and their replies on the same socket |
| HTTP to the venue | Balances, open orders, trades, exchange info, client-id lookup |
| gRPC | Monitoring and operator commands. Not market-data events |
| Journals | Local recovery material. Not venue truth |

## Laboratory path

- Exchange enum value: Paper.
- Indicator file path relative to the process working directory.
- Global trading starts disabled.
- Readiness stays failed until market data is fresh enough and the exchange snapshot is non-empty.
- The paper client allows one in-flight place, one cancel, and one amend.
- A composition binary can inject a research model into the same runner. That binary is not required for levels mode and is not started in the public demonstration.

![Trading runner](trading-runner.svg)
