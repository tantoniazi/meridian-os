# ADR-009: Mainline Kernel Strategy (6.6 LTS + Patches)

## Status
Accepted

## Context
Meridian OS supports four Linux-track device families with divergent kernel requirements:

| Device Family | SoC | Current Kernel | Patches |
|---------------|-----|----------------|---------|
| Nokia N900 | OMAP3 (ARMv7) | 6.6 LTS | ~30 patches (drivers, DT, PM) |
| Nokia N9 | OMAP3 (ARMv7) | 6.6 LTS | ~25 patches (shared with N900) |
| PinePhone | Allwinner A64 (ARM64) | 6.6 LTS | ~10 patches (modem, display, PM) |
| Librem 5 | i.MX8M Quad (ARM64) | 6.6 LTS | ~15 patches (modem, camera, PM) |

The Conexus spec emphasizes long-term support (5+ years) and upstream-first development. Vendor kernels (e.g., Allwinner 5.10, NXP 5.15) are EOL or unmaintained.

## Decision
**Track mainline Linux LTS (currently 6.6, next 6.12) with minimal out-of-tree patches.**

- Base kernel: `linux-6.6.y` from kernel.org (updated monthly via `git fetch --tags`)
- Device-specific configuration fragments in `kernel/configs/`:
  - `meridian-omap3_defconfig` (N900, N9)
  - `meridian-arm64_defconfig` (PinePhone, Librem 5, future ARM64)
- Patches only for:
  1. Drivers not yet upstream (queued for upstream submission)
  2. Device tree overlays for hardware not in mainline DT
  3. Power management tunables specific to Meridian PM policy
- **Upstream-first**: Every patch has a corresponding kernel.org mailing list thread or GitLab MR
- Patch series managed via `quilt` in `kernel/patches/<arch>/series` (e.g., `omap3/series`)
- CI builds kernel for each config on every LTS point release

## Consequences

### Positive
- **Long-term support**: 6.6 LTS supported until Dec 2027; 6.12 LTS until ~2029
- **Security updates**: Mainline receives CVEs fixes within days; no vendor backport lag
- **Hardware enablement**: New mainline drivers (e.g., Panfrost, Lima, `asoc-simple-card`) work automatically
- **Single source tree**: One kernel repo for all devices; config fragments isolate differences
- **Upstream credibility**: Patches accepted upstream reduce maintenance burden over time

### Negative
- **Hardware gaps**: Some peripherals lack mainline drivers (e.g., N900 FM radio, PinePhone GPS); require out-of-tree patches until upstreamed
- **OMAP3 aging**: TI OMAP3 mainline support is community-maintained; fewer reviewers
- **Config fragmentation**: Two defconfigs (ARMv7/ARM64) diverge over time; need periodic sync
- **Build time**: Full kernel build ~25 min on CI; mitigated by `ccache` and incremental builds

## Links
- [Linux 6.6 LTS announcement](https://lwn.net/Articles/949136/)
- [Meridian kernel configs](../kernel/configs/)
- [OMAP3 patch series](../kernel/patches/omap3/series)
- [PinePhone mainline status](https://wiki.pine64.org/wiki/Mainline_Kernel)
- [Librem 5 kernel status](https://developer.puri.sm/Librem5/Kernel/)
- [Conexus platform-infra: kernel CI pipeline](../.github/workflows/kernel.yml)