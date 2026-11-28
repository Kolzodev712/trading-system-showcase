# Contributing

This repository is the **ecosystem entry point**: documentation, diagrams, and the Paper laboratory under `lab/`.

Implementation work usually belongs in:

- https://github.com/Kolzodev712/trading_system
- https://github.com/Kolzodev712/k-paper
- https://github.com/Kolzodev712/trading-system-ui

Contribute here for lab scripts, showcase docs, scenarios, and cross-repo onboarding.

## Ground rules

- Keep `lab/` paper-only; no live credentials, operator tokens, or `.env` files.
- Do not commit `lab/artifacts/`.
- Prefer small documentation and tooling PRs with clear verification (`make doctor`, etc.).
- AI-assisted patches only if you reviewed and can explain them.

## Getting started

```bash
cd lab
cp .env.example .env
make doctor
# Optional full stack (Docker):
make build && make demo && make verify
```

## Pull requests

State which docs/scripts changed, how you verified them, and whether component pins (`lab/compatibility.json`) need updates.

## Reporting problems

- Lab / docs issues: this repository’s Issues.
- Component bugs: the owning implementation repository.
- Security: [SECURITY.md](SECURITY.md).

## License

Apache License 2.0 — see `LICENSE` and `NOTICE`.
