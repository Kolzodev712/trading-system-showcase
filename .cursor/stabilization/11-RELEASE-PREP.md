# Stabilization 11 — Release preparation

## Proposed version set (do not overwrite existing tags)

| Repo | Existing tags | Proposed next |
|------|---------------|---------------|
| trading_system | none | `v0.1.1` (stabilization) when owner approves tag |
| k-paper | none | `v0.1.1` |
| trading-system-ui | `v0.1.0` | `v0.1.1` |
| trading-system-showcase | none | `v0.1.1` |

## Publication commands (after tag approval)

```bash
# After mains are green and compatibility.json pins match tagged SHAs:
git -C trading_system tag -a v0.1.1 -m "Post-release stabilization"
git -C k-paper tag -a v0.1.1 -m "Post-release stabilization"
git -C trading-system-ui tag -a v0.1.1 -m "Post-release stabilization"
git -C trading-system-showcase tag -a v0.1.1 -m "Post-release stabilization"
# gh release create … per repo with notes from CHANGELOGs
```

**This step pushes `main`/`master` only.** Tags/releases require a separate owner OK.

## Supported install (source)

See `trading-system-showcase/lab/README.md` and `lab/compatibility.json`.
