# Slides

Eight slides for a technical conversation. Speak from the diagram and the running system. Do not add performance or production claims.

---

## 1. What this is

A Rust trading runner for market data, order execution, risk, and operator control.

The laboratory runs that runner against a local paper exchange and the existing browser UI.

It is not production complete and not mainnet ready. Implementation repositories are
being prepared for a reviewed public export under Apache 2.0 (UI remains MIT). This
conversation is about the design that is actually in the tree.

---

## 2. Architecture

One runner process.

Inside it: market data, exchange session, trading and risk, indicators, instrument rules, gRPC, health.

Beside it: the paper exchange, MongoDB, the UI, and a gRPC-Web proxy.

The browser does not connect to the exchange.

---

## 3. Boundaries

| Owner | Responsibility |
| --- | --- |
| Paper exchange | Book, balances, fills, fault hooks |
| Exchange session | Commands, acknowledgements, exchange state |
| Trading engine | Levels, risk, internal state, reconciliation |
| UI | Presentation and operator commands |
| Auth service | Demonstration login only |

Research binaries are not on this order path.

---

## 4. Concurrency

Engines run as asynchronous tasks in one process.

Market data and execution reports move on in-process channels.

Operator commands arrive on gRPC and are not turned into fake market events.

Sessions reconnect after a drop. A command in flight on a dead socket is failed.

No latency number is attached to this structure.

---

## 5. Orders and state

A level gets a price from an indicator, then a risk decision, then a place command.

The reply is read on the same socket that sent the command.

Client ids let a missing acknowledgement be looked up instead of placing twice.

The paper client keeps one in-flight place, cancel, and amend.

Trading state is reconciled to exchange state. It is not a second source of venue truth.

---

## 6. Recovery

Health stays failed until market data is fresh and the exchange snapshot is non-empty.

A disconnect is detected and the session is retried.

Bootstrap reconciliation runs at startup.

Pausing entries, cancelling working orders, and flattening are different commands.

Restarting the paper process drops its account. Reconciliation cannot invent that state again.

---

## 7. How it is tested

Unit tests for risk, the paper client, and reconciliation helpers.

Paper-exchange tests for fills and fault hooks.

A process harness that starts the paper exchange with the runner.

Browser tests for the UI.

The demonstration adds runtime checks. A check that does not see an order does not pass.

The paper exchange is a test double, not a clone of a production venue.

---

## 8. Trade-offs

In-process channels avoid a broker and share a failure domain.

A real paper client finds integration bugs that a "do not send" flag would hide, and it is not venue-API complete.

One in-flight command keeps acknowledgement handling simple and limits concurrency.

Fault hooks make failures repeatable and artificial.

Explicit risk limits can reject a bad order and say nothing about whether the level is a good idea.

Open limits: no durable paper account, no latency injector, tracing exporter left off, linear research stack not part of this demo.
