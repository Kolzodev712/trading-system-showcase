# Screenshots

Put captures here only after they are taken from the running demonstration. Do not add a mock, a design render, or a cropped image from another environment.

## What to capture

1. The spot monitor after sign-in, including the venue banner that says the session is paper and local.
2. The order book for the paper instrument.
3. Working orders or a recent fill, if the runner has produced one.
4. The levels panel.
5. The operator controls.

Skip the login form so the demonstration password is not in the image. Skip any panel that shows a host path, a connection string, or a token.

## How

1. `cd lab && make demo` in this public showcase repository.
2. Open `http://127.0.0.1:5173` and sign in.
3. Wait until the banner shows the paper venue.
4. Capture with the browser or the desktop tool at 1440×900 or larger.
5. Copy the files into this directory using names such as `01-spot-monitor.png`.

If a view is empty because no order has been placed, either wait for the level path or omit that shot. An empty state may be captured and captioned as empty. It may not be replaced with a drawing of orders.

## Captured

`01-spot-monitor.png` is from the running demonstration on 2026-11-26. It shows the spot monitor: paper/local/exchange banner, order book, balances, levels, one working order, and recent executions. Trading was off in that frame because the runner had just been recreated. The sign-in page is not included. It displays the development password in the page text.

Review the image before publishing. The corner shows the demonstration username. `.gitignore` ignores `*.png` until you decide to commit a reviewed capture.
