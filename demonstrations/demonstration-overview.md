# Demonstration overview

The private environment builds the existing runner, paper exchange, and UI. It does not contain a second trading implementation.

After the services are healthy, the local UI is at `http://127.0.0.1:5173` and runner health is at `http://127.0.0.1:8080/health`. Nothing else is published, and the published ports bind to loopback. The container network does not masquerade traffic to the public internet.

Scenarios that the environment can run, when the underlying evidence appears:

| Command | What it checks |
| --- | --- |
| `make scenario SCENARIO=normal-execution` | Connectivity plus a **new** paper order or trade correlated with runner place ACK or execution (stale orders alone do not pass) |
| `make scenario SCENARIO=partial-fills` | `lab_fill_open` on a resting order the runner ACK’d; REST shows partial fill state |
| `make scenario SCENARIO=exchange-disconnect` | Paper disconnect, reconnect attempt, then trade socket connected again |
| `make scenario SCENARIO=reconciliation` | Bootstrap reconciliation start **and** completion logs at startup |
| `make scenario SCENARIO=risk-rejection` | `risk-rejection` profile with a post-switch `blocked by risk check` log |
| `make scenario SCENARIO=operator-control` | Pause and resume through gRPC with status before, during, and after |
| `make scenario SCENARIO=observability` | JSON logs and the health endpoint |

`lost-ack` arms the suppress-ACK hook only and always exits blocked; it does **not** claim recovery. Lab faults are cleared with `reset_lab_faults` before exit. Latency injection is not available. A scenario that cannot see its evidence does not pass.

The recording procedure is [video.md](video.md). No recording is shipped in this repository.
