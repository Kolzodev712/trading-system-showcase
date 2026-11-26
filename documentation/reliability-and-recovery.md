# Reliability and recovery

## Readiness

The health endpoint returns failure until the market-data view is fresh enough and the exchange snapshot has balances or orders. A proxy or a UI that waits on that endpoint does not treat a half-started runner as ready. There is a short grace period after process start before freshness is enforced.

## Disconnect

A paper test hook can close client sockets. The trade session logs a reconnect and retries. The market-data session retries as well. Commands that were open on the dropped socket are failed. This shows detection and a new session. It does not show that every in-flight order was filled.

## Missing acknowledgement

The paper server can accept an order and withhold the place acknowledgement. The runner's paper client treats a timeout as unresolved and can query by client id. It does not allocate a second client id for that attempt while the first is unknown. The full drill used in development restarts the runner while the paper process keeps the order. The short demonstration arms the hook and does not claim that restart drill unless it is actually run.

## Reconciliation

Bootstrap reconciliation runs at startup and is logged. Later passes use the configured interval. They compare trading positions and working orders with exchange state. If the paper process restarts, its memory is empty and reconciliation has nothing durable on the venue side to restore. The runner's own journals survive only as long as its data volume does. The demonstration reset deletes that volume on purpose.

## Risk and operator stops

A risk block prevents the place call. Pausing entries stops new entry orders. Cancelling working orders is a separate command. Flatten is a separate command and is journaled before send, with a stable client id. Those controls are the recovery tools an operator has. They are not an automatic guarantee that the venue is flat. A successful cancel response is not treated as an empty book until a further check says so.

## What is switched off

The Jaeger exporter is disabled because it panics under the Tokio runtime the project currently uses. Prometheus is not attached, so the metrics route reports that metrics are not configured. Logs are structured JSON in the demonstration. Health is the liveness signal that Compose waits for.
