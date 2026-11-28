# Maintainer workflow (lightweight)

## Issue lifecycle

`New` → `Triage` → `Discussion` → `Accepted scope` → `Implementation` → `Review` → `Verification` → `Merge` → `Release`

| Situation | Action |
|-----------|--------|
| Duplicate | Close with link to canonical issue |
| Insufficient reproduction | Label `needs-reproduction`; ask for revision, env, sanitized logs |
| Unsolicited large feature | Label `needs-design`; no commitment to implement |
| Breaking / architectural | Require prior discussion; may defer |
| Security-sensitive | Follow `SECURITY.md`; do not discuss exploits in public issues |
| Abandoned PR | Ping once; close after reasonable silence; welcome reopen |
| Unsupported request | Decline politely; optionally note demand-driven backlog |

Do **not** commit to implement every request. Prioritize user demand and engineering quality.

## Pull-request acceptance

Accept based on correctness, architectural fit, maintainability, verification evidence, user value, and security — not contributor counts.

High scrutiny: risk, execution authorization, order ACK handling, journaling, reconciliation, recovery, auth, credentials, financial accounting.

## Release management

Preserve compatible-version pins (`lab/compatibility.json`), protobuf compatibility, integration qualification, and docs consistency across repos. No GitHub Actions; rely on documented local commands.
