# Community & adoption preparation — final report

**Date:** 2026-11-28  
**Status:** Local changes prepared. **No commit, push, remote settings, issues, or external posts** until owner approval.

## 1. Changes implemented locally (uncommitted)

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

## 2. Proposed descriptions & topics

See `.cursor/community/commands/01-github-discoverability.sh` (exact `gh repo edit` commands).  
**Topic accuracy:** `backtesting` OK (research_cli); others match implemented surfaces. k-paper description should replace weak “Paper exchange integration”.

**Profile pins (manual UI):** trading_system, k-paper, trading-system-ui, trading-system-showcase, company-ai-poc, cursor-hub.

## 3. Proposed labels

See `.cursor/community/commands/05-labels.sh`.

## 4. Draft contribution issues (15)

Index: `.cursor/community/drafts/issues/INDEX.md`  
Bodies: KP-1…KP-5, TS-1…TS-4, UI-1…UI-3, SC-1…SC-3  
**Not published.**

## 5. Discussions welcome draft

`.cursor/community/drafts/discussions-welcome.md`  
Enable Discussions on showcase only: `commands/07-enable-discussions.sh`.

## 6. Ecosystem roadmap

`ROADMAP.md` (tracked, uncommitted).

## 7. Outreach drafts (local only)

`.cursor/community/outreach/` (gitignored): descriptions, announcements, TWiR/Up-for-Grabs drafts, article outlines.

## 8. Exact remote commands (approval required)

```bash
# Discoverability
bash .cursor/community/commands/01-github-discoverability.sh

# Labels (all four repos)
bash .cursor/community/commands/05-labels.sh

# Discussions: use GitHub settings UI for showcase
bash .cursor/community/commands/07-enable-discussions.sh
```

Then: commit/push local trees → create issues from drafts → optional TWiR (max 2 issues).

## 9. Verification

| Check | Result |
|-------|--------|
| Phase 0 metadata via `gh` | PASS (empty descriptions/topics; no templates remotely yet) |
| Stale research-export CONTRIBUTING claim | Fixed locally |
| Relative README cross-links (TS/UI/k-paper) | Fixed to absolute GitHub URLs |
| Issue template YAML present in all four | PASS (local) |
| No fabricated stats/testimonials | PASS |
| No trading architecture changes | PASS |
| No GitHub Actions added | PASS |
| Outreach not in tracked public paths | PASS (`outreach/` gitignored) |
| Contributor tasks not implemented | PASS (drafts only) |

## 10. Remaining owner decisions

1. Approve commit + push of local community files.
2. Approve running discoverability + label scripts.
3. Approve enabling Discussions + welcome post.
4. Approve which draft issues to publish (recommend KP-1, KP-2, TS-1, SC-1 first).
5. Approve any external announcement / TWiR submission after issue URLs exist.
