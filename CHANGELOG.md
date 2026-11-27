# Changelog

## [Unreleased]

## [0.1.1] — 2026-11-27

### Added

- Compatibility pins (`lab/compatibility.json`) and release-mode Git staging for all components.
- Structured Paper config validation (`validate-config.py`) with negative fixtures.
- Read-only `make verify`, `make qualify`, scenario evidence hardening; lost-ack remains BLOCKED.
- Stabilization tracker under `.cursor/stabilization/`.
- Reviewed `screenshots/01-spot-monitor.png`.

### Fixed

- Sibling paths `../../…` from `lab/`; k-paper market config uses tick-based fields.
- Offline bundle ships `validate-config.py`; runner/ops images include `python3`.
