# ADR-007: OSTree for Atomic Updates on Linux Devices

## Status
Accepted

## Context
Meridian OS targets Linux-based mobile devices (Nokia N900, N9, PinePhone, Librem 5) running Debian-based root filesystems. The Conexus specification (ADR-003) defines A/B partition updates for Android-track devices, but Linux devices have different constraints:

- Debian/APT ecosystem expects package-based updates
- Devices have limited storage (eMMC 4–32 GB)
- Users expect atomic upgrades with instant rollback
- Reproducible, bit-for-bit identical deployments across device fleets
- No dedicated recovery partition like Android's `recovery` / `boot` slots

OSTree provides a content-addressed, git-like model for filesystem trees with atomic checkout, bootloader integration, and delta updates.

## Decision
Use **OSTree** as the update mechanism for all Linux-track devices (OMAP3, ARM64 mainline).

- Base OS delivered as an OSTree commit (`ostree commit --repo=/ostree/repo`)
- Bootloader (U-Boot/GRUB) loads kernel/initramfs from OSTree via `ostree=...` kernel cmdline
- Updates pulled via `ostree pull` from a signed summary file; applied atomically on next boot
- Rollback is a single `ostree admin rollback` (or GRUB menu selection)
- `/var` and `/etc` are bind-mounted from a persistent overlay (`/ostree/deploy/meridian/var`)

Signing infrastructure (cosign/Reproducible Builds) is shared with the Android A/B pipeline (see ADR-012).

## Consequences

### Positive
- **Atomic upgrades/rollbacks**: No half-applied state; power loss during update = boot previous commit
- **Reproducible deployments**: Same commit hash = identical filesystem across 1,000+ devices
- **Delta updates**: Only changed objects transferred (typically 10–50 MB vs full image)
- **Debian-native**: Works with `apt`/`dpkg` build pipeline; `ostree compose` from `.deb` packages
- **Bootloader agnostic**: U-Boot (ARM) and GRUB (x86) both support OSTree boot protocol

### Negative
- **Disk space overhead**: Each commit retains previous versions; requires ~2–3× base OS size for 3–5 rollbacks
- **Learning curve**: Team must understand OSTree model (commits, refs, deployments) vs traditional APT
- **/usr merge required**: OSTree expects merged `/usr`; Debian `usrmerge` package handles this
- **No live patching**: Kernel updates still require reboot (mitigated by kexec fast-reboot)

## Links
- [OSTree documentation](https://ostreedev.github.io/ostree/)
- [Conexus ADR-003: A/B Partition Updates for Android](adr-003-ab-partition-updates.md)
- [ADR-012: Dual Update Strategy](adr-012-dual-update-strategy.md)
- [Meridian bootloader configs](../bootloader/u-boot/configs/)