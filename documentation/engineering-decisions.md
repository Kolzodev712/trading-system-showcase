# Engineering decisions

## Exchange client instead of a paper flag

**Problem.** The same runner has to talk to more than one venue, including a local one, without a second order implementation.

**Constraint.** The local venue must be unable to reach a real exchange from the demonstration network. A boolean that means "do not send" would hide integration bugs and would be easy to mis-set.

**Approach.** `Paper` is an exchange client with its own socket and HTTP mapping. The demonstration also rejects a configuration that names another venue or a non-local URL, and the container network does not masquerade to the public internet.

**Trade-off.** Every venue client has to be maintained. The paper client is not a full copy of any production venue's API.

**Check.** The runner logs a paper connection, and its status labels the venue as paper and the environment as local.

**Limit.** Other clients exist in the private tree. They are unused in this demonstration. Their presence is not a claim that each of them is production ready.

## In-process events, RPC for the operator

**Problem.** Market data and execution events are frequent. Operator commands are rare and must be explicit.

**Constraint.** The browser cannot speak the runner's native gRPC without a proxy, and it must not open an exchange socket.

**Approach.** Engines inside the runner use channels. The control service is gRPC. Envoy presents that service as gRPC-Web. Commands are not published onto the market-data channel.

**Trade-off.** The engines share a process and a failure domain. Splitting them would add a network hop that this design does not pay.

**Check.** The UI receives monitoring data only after the proxy and the runner are up. Stopping the paper process does not require the UI to reconnect to it, because the UI was never connected to it.

**Limit.** Channel fan-out is not a measured latency product. No microsecond figure is stated.

## Reconciliation beside the socket

**Problem.** A dropped message or a restart can make internal orders disagree with the venue.

**Constraint.** The paper account is in memory, and HTTP is eventually consistent with the socket from the client's point of view.

**Approach.** Exchange state is updated from the socket and refreshed from HTTP. Trading state is reconciled to that exchange state on startup and on an interval. A missing acknowledgement can be resolved by client-id lookup instead of placing a second order. The paper client keeps a single in-flight command of each kind so it does not pipeline ambiguous places.

**Trade-off.** One in-flight command limits concurrency on the paper client. That is accepted for the laboratory. Lookup-after-cancel and suppressed-ack behavior exist in the paper server and in runner tests; the showcase does not automate the historical restart drill.

**Check.** The runner logs bootstrap reconciliation. A planted mismatch is a further test, not something this page claims to have displayed.

**Limit.** Restarting the paper process deletes the account. Reconciliation cannot restore an account the venue has forgotten.

## Risk before send

**Problem.** A level can request an order larger than the configured book of risk.

**Constraint.** Exchange mode must not start with an empty limit set. Shadow mode may omit it. The demonstration runs exchange mode against the paper client, so the limit set is required.

**Approach.** Pre-trade checks return allow or block. The level logs the block and does not call place.

**Trade-off.** Daily-loss checks depend on the execution ledger having figures. A fresh process with no losses will not demonstrate that particular check. Quantity and count caps can be demonstrated by configuration.

**Check.** A profile whose maximum order quantity is below the level size produces a risk-block log and no extra paper order from that attempt.

**Limit.** This is a control demonstration, not a statement about strategy quality.

## Paper exchange as a laboratory, not a clone

**Problem.** Failures need to be repeatable.

**Constraint.** The paper server must stay a test double. Pretending it is a named production venue would be false.

**Approach.** Synthetic books, scripted scenarios, and one-shot HTTP fault hooks. Spot accounting is the default. A linear contract fixture exists and is not what the browser demonstration starts.

**Trade-off.** Hooks make failures deterministic and also make them artificial. A hook result is evidence about the runner's reaction to that hook, not about a production venue's matching engine.

**Check.** Disconnect, partial fill, and suppressed acknowledgement are separate HTTP calls on the paper server. Each scenario reports only the evidence it observed.

**Limit.** There is no latency injector. Partial fills are a hook, not the default fill model.
