# Demonstration overview

The private environment builds the existing runner, paper exchange, and UI. It does not contain a second trading implementation.

After the services are healthy, the local UI is at `http://127.0.0.1:5173` and runner health is at `http://127.0.0.1:8080/health`. Nothing else is published, and the published ports bind to loopback. The container network does not masquerade traffic to the public internet.

Scenarios that the environment can run, when the underlying evidence appears:

| Command | What it checks |
| --- | --- |
| `make scenario SCENARIO=normal-execution` | Paper connection, balances, and a runner or paper order produced by levels mode |
| `make scenario SCENARIO=partial-fills` | A laboratory partial fill of an order the runner already placed |
| `make scenario SCENARIO=exchange-disconnect` | A paper disconnect followed by the runner's reconnect log |
| `make scenario SCENARIO=reconciliation` | The bootstrap reconciliation log |
| `make scenario SCENARIO=risk-rejection` | A tighter quantity cap and a risk-block log |
| `make scenario SCENARIO=operator-control` | Pause and resume through gRPC |
| `make scenario SCENARIO=observability` | JSON logs and the health endpoint |

`lost-ack` is present as a hook check and does not pass, because the recovery drill is not automated. Latency injection is not available. A scenario that cannot see its evidence does not pass.

The recording procedure is [video.md](video.md). No recording is shipped in this repository.
