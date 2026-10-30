# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records for Meridian OS, aligned with the Conexus platform specification.

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [007](007-ostree-atomic-updates.md) | OSTree for Atomic Updates on Linux Devices | Accepted | 2026-10-30 |
| [008](008-qt6-kirigami-ui-framework.md) | Qt6/Kirigami for UI Framework | Accepted | 2026-10-30 |
| [009](009-mainline-kernel-strategy.md) | Mainline Kernel Strategy (6.6 LTS + Patches) | Accepted | 2026-10-30 |
| [010](010-w10m-controls-library.md) | W10M Controls as Extractable Library | Accepted | 2026-10-30 |
| [011](011-rust-system-services.md) | Rust for New System Services (ADR-005 Alignment) | Accepted | 2026-10-30 |
| [012](012-dual-update-strategy.md) | Dual Update Strategy (OSTree + A/B) | Accepted | 2026-10-30 |

## Conexus Alignment

These ADRs implement Meridian-specific decisions that align with the following Conexus ADRs:

- **Conexus ADR-003**: A/B Partition Updates for Android → **Meridian ADR-012** (dual strategy)
- **Conexus ADR-005**: Rust for Userspace → **Meridian ADR-011** (Rust system services)
- **Conexus Design System**: Cross-platform tokens/components → **Meridian ADR-008/010** (Qt implementation + W10M extraction)

## Format

Each ADR follows the standard structure:

```markdown
# ADR-XXX: Title

## Status
[Proposed | Accepted | Superseded | Deprecated]

## Context
Problem statement and background.

## Decision
The chosen approach.

## Consequences
### Positive
Benefits and opportunities.

### Negative
Costs, risks, and trade-offs.

## Links
References to related docs, specs, code.
```

## Contributing

1. Create new ADR as `NNN-short-title.md` (next sequential number)
2. Use `Proposed` status initially
3. Discuss in PR; merge moves to `Accepted`
4. Supersede old ADRs by linking `Supersedes: ADR-XXX` in new ADR