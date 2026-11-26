# Testing methodology

Testing is split between the private codebases and the demonstration runtime.

## In the trading runner

Crate tests cover risk decisions, paper client behavior, reconciliation helpers, and runner configuration. A workflow harness can start the paper exchange and the runner as processes and assert on journals and status. Those tests are the place where ambiguous submissions and restart recovery are pinned down. This repository does not copy their source or their output.

## In the paper exchange

Core tests cover matching, balances, client-id lookup, and the one-shot fault hooks, including a partial fill that leaves a remainder. Server integration tests bind a fixed port and are documented to run single-threaded for that reason. The paper tests do not claim parity with a production venue.

## In the UI

Unit tests cover transforms, operator commands, and store behavior. A browser harness exists for paper end-to-end flows. The UI tests do not decide whether an order was accepted. The runner does.

## In the demonstration

`make verify` checks the composed system: the containers cannot open a public HTTP route, the runner health endpoint is ready, the UI and the login API respond, the runner's own status says the venue is paper and the environment is local, and at least one real order or fill is visible from the runner or the paper exchange. Scenario commands look for the same kind of evidence: a log line, an HTTP body, or a gRPC status. A scenario that does not see that evidence exits with a distinct code and does not print a pass.

These runtime checks can fail because the level has not warmed up yet. That failure is reported. It is not replaced with a scripted order that bypasses the runner.

## What is not claimed

A green build is not an integration result. A paper fill is not a performance measurement. A unit test name is not evidence that the composed demonstration passed.
