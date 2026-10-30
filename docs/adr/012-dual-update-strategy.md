# ADR-012: Dual Update Strategy (OSTree + A/B)

## Status
Accepted

## Context
Meridian OS spans two distinct hardware tracks with incompatible update mechanisms:

| Track | Devices | Current Mechanism | Conexus Spec |
|-------|---------|-------------------|--------------|
| **Linux** | N900, N9, PinePhone, Librem 5, generic ARM64/x86 | OSTree (ADR-007) | Not specified |
| **Android** | Pixel 7a+, generic GSI targets | A/B partitions (seamless) | ADR-003 |

The Conexus platform requires:
- **Unified signing/verification**: Same root of trust for all device images
- **Platform-agnostic rollback API**: Apps/services call `conexus.ota.Rollback()` regardless of track
- **Single CI pipeline**: Build → Sign → Publish → Stage → Rollout for both tracks
- **Delta updates**: Minimize bandwidth (critical for mobile data)

## Decision
**Per-track update mechanism with shared signing infrastructure and unified rollback API.**

### Linux Track → OSTree (per ADR-007)
- Compose: `ostree compose` from Debian packages → commit
- Sign: `cosign sign --key=cosign.key ostree-commit-<hash>`
- Publish: OSTree static delta repo (NGINX + `summary` file) + TUF metadata
- Client: `ostree pull --verify-signature` → `ostree admin deploy` → reboot

### Android Track → A/B Partitions (per Conexus ADR-003)
- Build: `make -j$(nproc) target-files-package otapackage`
- Sign: `sign_target_files_apks` + `otatools/sign_ota_package` (AVB 2.0)
- Publish: OTA JSON index + incremental `.zip` on CDN
- Client: `update_engine` (A/B) + `conexus-ota` daemon for policy

### Shared Infrastructure
| Component | Implementation |
|-----------|----------------|
| **Root of trust** | `cosign`/`fulcio`/`rekor` (sigstore); keys in HSM (YubiHSM/AWS KMS) |
| **SBOM** | `syft` generates SPDX for each artifact; stored in `rekor` |
| **Policy engine** | `conexus-ota` daemon (Rust, ADR-011) evaluates: channel, battery, network, maintenance window |
| **Rollback API** | D-Bus: `org.conexus.OTA1.Rollback()` → Linux: `ostree admin rollback`; Android: `update_engine` `Rollback()` |
| **CI pipeline** | Single `.github/workflows/release.yml` matrix: `track: [linux, android]` |

### Versioning
- **Unified version**: `MAJOR.MINOR.PATCH-TRACK.BUILD` (e.g., `2026.10.0-linux.42`, `2026.10.0-android.42`)
- Same `MAJOR.MINOR.PATCH` = feature parity across tracks
- Track-specific `BUILD` for kernel/firmware differences

## Consequences

### Positive
- **Right tool per track**: OSTree for Debian-based Linux; A/B for Android (no forced convergence)
- **Single source of truth**: Sigstore signing, SBOM, policy engine shared
- **App developer simplicity**: One `conexus-ota` client library; same rollback API
- **Operational consistency**: Same staging/rollout/canary process for both tracks
- **Auditability**: Rekor transparency log covers all device artifacts

### Negative
- **Two pipelines to maintain**: OSTree compose vs Android `otapackage`; different failure modes
- **Testing matrix**: Must validate OTA on 4+ Linux devices + 3+ Android devices per release
- **Rollback semantics differ**: OSTree = previous commit (instant); Android = inactive slot (reboot)
- **Disk space**: Linux needs OSTree repo (~2–3 GB); Android needs 2× system partition (~4–6 GB)

## Links
- [ADR-007: OSTree for Atomic Updates](adr-007-ostree-atomic-updates.md)
- [Conexus ADR-003: A/B Partition Updates](https://github.com/conexus-systems/.../adr-003-ab-partition-updates.md)
- [sigstore/cosign](https://docs.sigstore.dev/)
- [update_engine (Android)](https://source.android.com/docs/core/ota/ab)
- [conexus-ota daemon design](../system/rust/conexus-ota/README.md) (to be created)
- [Release CI workflow](../.github/workflows/release.yml)