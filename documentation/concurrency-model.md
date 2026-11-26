# Concurrency and events

The runner is an asynchronous Rust process. Each engine owns its session or its state loop. Market-data updates and execution reports are delivered to the trading and indicator logic on broadcast channels inside the process. That choice keeps the laboratory path free of an extra broker. It also means a stall in the process stalls every engine together.

The paper market-data client runs a read loop. When the loop returns, it waits and connects again. The paper trade client does the same after a disconnect and fails any command that was in flight on the dead socket, rather than leaving it marked connected.

Operator commands enter through the gRPC server. They call the same trading-control state the engines already consult. They are not enqueued as synthetic market events. The browser reaches that server through a proxy that translates gRPC-Web. A Lua filter on the proxy can attach an operator token from a server-side file. The paper demonstration leaves that file empty.

MongoDB access is part of startup and of configuration persistence. It is not on the path that applies a single order-book update.

Optional Zenoh publication of events is compiled in and left off. Turning it on would add a network bus beside the in-process channels. The demonstration does not need that bus to show the control plane.

No throughput or scheduling-latency number is published here. The structure above is the concurrency model. It is not a performance result.
