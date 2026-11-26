# Recording procedure

No video has been recorded from this repository. Do not upload a recording automatically. Record only after `make verify` has passed on the machine you will use.

## Title

Trading system laboratory: paper execution, recovery, and operator control

## Description

A five-minute look at a Rust trading runner connected only to a local paper exchange, with the existing browser UI. The system is a laboratory codebase, not a production or mainnet system. The recording shows the running processes, one order lifecycle, a disconnect, a risk rejection, and the limits of the paper account.

## Before recording

1. `make demo` and wait until the UI URL is printed.
2. Sign in with the local demonstration account. Do not speak or type a password on camera if the video will be public. Cut the login or blur it.
3. Confirm the status banner says the venue is paper and the environment is local.
4. Close editor tabs that show source, environment files, or credentials.
5. Run `make scenario SCENARIO=normal-execution` once so you know whether an order is already on the book.

## OBS Studio

- Canvas 1920x1080, 30 fps.
- One scene: the browser, full screen, at 100% zoom on the UI.
- A second scene: the architecture diagram from `architecture/system-overview.md`, opened in a browser or a local preview.
- A third scene: a terminal, font size at least 18, only the demonstration directory.
- Audio: narration only. Mute notification sounds.
- Do not capture another desktop or a password manager.

## Timeline

| Time | On screen | Narration | Command |
| --- | --- | --- | --- |
| 0:00 | Diagram | This is one trading process. Market data, risk, and orders live inside it. The paper exchange is a separate process. The browser talks only to the runner. | none |
| 0:30 | Diagram | The point of the laboratory is to run that same runner without a real venue. The network cannot reach one. | none |
| 1:00 | UI spot monitor | The book on screen is the synthetic paper book. Balances come from the paper account through the runner. | none |
| 2:00 | UI orders, then terminal | Levels submit through the risk check and the paper client. This is an order the runner placed, not a fixture painted into the UI. | `make scenario SCENARIO=normal-execution` if you need the check on camera |
| 3:00 | Terminal logs | Disconnecting the paper clients makes the trade session fail the old socket and connect again. | `make scenario SCENARIO=exchange-disconnect` |
| 4:00 | UI controls, then terminal | Pausing entries is separate from cancelling orders. A quantity above the configured cap is rejected before it is sent. | pause in the UI, then `make scenario SCENARIO=risk-rejection` |
| 4:30 | Diagram | Channels inside the process, gRPC for the operator, reconciliation against the exchange snapshot. The paper account is memory. Restarting it drops the account. This is not a production deployment and not a performance result. | none |

If a scenario exits without a pass, say so and skip that sentence. Do not leave the failed command out of the take and describe the result anyway.

## Reset between takes

`make reset` in the demonstration directory. It affects only that Compose project. Then wait for `make demo` to report ready again.

## After recording

Keep the file locally. Review it for account names, host paths, and configuration values before anyone else sees it. This repository is not the place to commit the video.
