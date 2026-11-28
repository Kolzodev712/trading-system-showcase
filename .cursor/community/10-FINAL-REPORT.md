# Community & adoption preparation — final report

**Date:** 2026-11-28  
**Status:** Community preparation committed and pushed. Activation (descriptions, labels, issues, Discussions) proceeds under the Final Community Activation brief.

## 1. Changes shipped (committed on public remotes)

### trading_system
- `CONTRIBUTING.md` — research public; contribution policy; verification commands
- `.github/ISSUE_TEMPLATE/*`, `pull_request_template.md`
- `README.md` — absolute GitHub links to showcase lab

### k-paper
- `CONTRIBUTING.md` expanded
- `.github/` templates
- `README.md` — absolute showcase link; Contributing section

### trading-system-ui
- `CONTRIBUTING.md` expanded
- `.github/` templates
- `README.md` — absolute lab link; Limitations + Contributing

### trading-system-showcase
- `CONTRIBUTING.md` expanded
- `.github/` templates
- `ROADMAP.md`, `docs/MAINTAINER_WORKFLOW.md`
- `README.md` — roadmap/contributing pointers
- `.cursor/community/**` — assessment, drafts, commands; `outreach/` gitignored

## 2. Discoverability (activation)

Commands: `.cursor/community/commands/01-github-discoverability.sh`  
**Topic accuracy:** `backtesting` OK (research_cli); others match implemented surfaces.

**Profile pins (manual UI):** trading_system, k-paper, trading-system-ui, trading-system-showcase, company-ai-poc, cursor-hub.

## 3. Labels

Commands: `.cursor/community/commands/05-labels.sh` (idempotent create-or-edit).

## 4. Contribution issues

Index: `.cursor/community/drafts/issues/INDEX.md`  
Initial publish set (activation): KP-1, KP-2, KP-4, TS-1, TS-3, TS-4, UI-3, SC-1.  
Held as unpublished / design: KP-3, KP-5, TS-2, UI-1, UI-2, SC-2, SC-3.

## 5. Discussions

Showcase Discussions hub; welcome post from `drafts/discussions-welcome.md`.

## 6. Ecosystem roadmap

`ROADMAP.md` — update with published issue URLs after activation.

## 7. Outreach drafts (local only)

`.cursor/community/outreach/` (gitignored): descriptions, announcements, TWiR/Up-for-Grabs drafts, article outlines.

## 8. Historical note

Earlier sections of this report described the same content as **local / uncommitted** pending owner approval. That gate is closed: the community files above are on the public default branches. Treat this file as the activation ledger, not a pre-push checklist.

## 9. Verification posture

| Check | Result |
|-------|--------|
| Community templates on remotes | PASS (pushed) |
| Stale research-export CONTRIBUTING claim | Fixed |
| Relative README cross-links (TS/UI/k-paper) | Absolute GitHub URLs |
| No fabricated stats/testimonials | PASS |
| No trading architecture changes | PASS |
| No GitHub Actions added | PASS |
| Outreach not in tracked public paths | PASS (`outreach/` gitignored) |
| Contributor tasks not implemented by maintainers as part of activation | PASS |

## 10. Remaining owner actions (external)

1. Pin repositories on the GitHub profile UI.
2. Record / upload demonstration video if desired.
3. Publish LinkedIn / Show HN / TWiR / community posts from outreach drafts (after issue URLs filled in).
