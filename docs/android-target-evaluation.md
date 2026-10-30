# Android Device Evaluation Matrix for First Conexus Android Target

## 1. Selection Criteria (from Conexus ADR-002)

| # | Criterion | Description | Weight |
|---|-----------|-------------|--------|
| 1 | **Unlockable Bootloader** | Official or documented unlock method without carrier/region restrictions | Critical |
| 2 | **Mainline Kernel Support** | Upstream Linux kernel support or maintained device tree with recent LTS | High |
| 3 | **Vendor Blobs** | Legally extractable and distributable proprietary blobs (firmware, drivers) | Critical |
| 4 | **Active Community** | Active LineageOS, AOSP, or custom ROM development community | High |
| 5 | **Recovery Method** | Fastboot, EDL mode, or TWRP availability for flashing/recovery | High |
| 6 | **Hardware Documentation** | Public schematics, datasheets, or open devices program | Medium |
| 7 | **No Hard-Brick Risk** | Recoverable without JTAG/hardware programmer | Critical |

---

## 2. Candidate Devices Evaluation

### Scoring: 1 = Poor, 2 = Below Average, 3 = Acceptable, 4 = Good, 5 = Excellent

| Device | Bootloader | Kernel | Blobs | Community | Recovery | Docs | Risk | **Total** |
|--------|------------|--------|-------|-----------|----------|------|------|-----------|
| **Google Pixel 7a** | 5 | 4 | 5 | 5 | 5 | 4 | 5 | **33** |
| **Google Pixel 6a** | 5 | 4 | 5 | 5 | 5 | 4 | 5 | **33** |
| **Fairphone 5** | 5 | 5 | 4 | 4 | 4 | 5 | 5 | **32** |
| **Nothing Phone (2)** | 5 | 4 | 4 | 4 | 4 | 3 | 4 | **28** |
| **OnePlus 11** | 5 | 3 | 3 | 4 | 4 | 3 | 4 | **26** |
| **Sony Xperia 1 V** | 4 | 3 | 3 | 3 | 4 | 5 | 4 | **26** |
| **Google Pixel 5a** | 5 | 4 | 5 | 5 | 5 | 4 | 5 | **33** |
| **SHIFT6mq** | 5 | 5 | 3 | 2 | 3 | 5 | 4 | **27** |
| **Motorola Edge 40** | 4 | 3 | 3 | 3 | 3 | 3 | 3 | **22** |
| **Xiaomi 13** | 3 | 3 | 3 | 4 | 4 | 2 | 3 | **22** |

### Detailed Device Analysis

#### Google Pixel 7a (Primary Recommendation)
- **Bootloader**: 5/5 — Official unlock via `fastboot flashing unlock`, no wait period, no carrier locks on retail units
- **Kernel**: 4/5 — Tensor G2 mainline support advancing rapidly (linux-mainline 6.6+), Google provides GKI kernels
- **Blobs**: 5/5 — Extractable from factory images, legally redistributable under Google's OSS-friendly policy
- **Community**: 5/5 — Official LineageOS 21 support, active GrapheneOS/CalyxOS ports, massive XDA presence
- **Recovery**: 5/5 — Fastbootd + fastboot flash, factory images, Pixel Flash tool, no EDL needed
- **Docs**: 4/5 — Public kernel source, hardware abstraction layers documented, no schematics but excellent AOSP integration
- **Risk**: 5/5 — Virtually unbrickable via fastboot mode, no JTAG required

#### Google Pixel 6a (Strong Alternative)
- **Bootloader**: 5/5 — Same official unlock as 7a
- **Kernel**: 4/5 — Tensor GS101 mainline support mature (6.1+ LTS), GKI kernels available
- **Blobs**: 5/5 — Same extraction/distribution model as 7a
- **Community**: 5/5 — LineageOS 21 official, GrapheneOS/CalyxOS, very mature device tree
- **Recovery**: 5/5 — Identical fastboot workflow
- **Docs**: 4/5 — Same as 7a, slightly more mature kernel tree
- **Risk**: 5/5 — Same unbrickable profile

#### Fairphone 5
- **Bootloader**: 5/5 — Official unlock supported by manufacturer
- **Kernel**: 5/5 — Mainline-first philosophy, QCM6490 upstreamed, 5+ years kernel support commitment
- **Blobs**: 4/5 — Most blobs open, some modem/camera firmware proprietary but extractable
- **Community**: 4/5 — LineageOS official, /e/OS, community smaller than Pixel but dedicated
- **Recovery**: 4/5 — Fastboot unlock, TWRP available, EDL not needed
- **Docs**: 5/5 — Full schematics published, modular design documented, repair manuals public
- **Risk**: 5/5 — Designed for repairability, no hard-brick scenarios documented

#### Nothing Phone (2)
- **Bootloader**: 5/5 — Official unlock via fastboot, no wait period
- **Kernel**: 4/5 — Snapdragon 8+ Gen 1 mainline support good, Nothing publishes kernel source
- **Blobs**: 4/5 — Extractable from OTA, some camera/modem blobs proprietary
- **Community**: 4/5 — LineageOS official, active XDA, growing but younger than Pixel
- **Recovery**: 4/5 — Fastboot + TWRP, no EDL required
- **Docs**: 3/5 — Kernel source published, no schematics, limited hardware docs
- **Risk**: 4/5 — Recoverable via fastboot, EDL as last resort

#### OnePlus 11
- **Bootloader**: 5/5 — Official unlock, but wait period (7 days) and OEM unlock toggle
- **Kernel**: 3/5 — Snapdragon 8 Gen 2 mainline WIP, OnePlus kernel source delayed
- **Blobs**: 3/5 — Extractable but more proprietary components, camera firmware especially
- **Community**: 4/5 — LineageOS official, strong XDA, OxygenOS open betas help
- **Recovery**: 4/5 — Fastboot + TWRP, EDL available but complex
- **Docs**: 3/5 — Kernel source eventually published, no schematics
- **Risk**: 4/5 — EDL recovery possible but requires authorized account or exploit

#### Sony Xperia 1 V
- **Bootloader**: 4/5 — Open Devices Program, official unlock but requires Sony account + IMEI registration
- **Kernel**: 3/5 — Snapdragon 8 Gen 2, Sony upstream contributions but device trees lag
- **Blobs**: 3/5 — Sony provides some binaries, camera stack heavily proprietary
- **Community**: 3/5 — LineageOS unofficial, smaller community, AOSP reference device but not consumer-focused
- **Recovery**: 4/5 — Fastboot + flash tool (Emma), EDL not typical
- **Docs**: 5/5 — Best documentation: public schematics, kernel config, AOSP device trees
- **Risk**: 4/5 — Recoverable via flash tool, but bootloader relock risks

#### Google Pixel 5a
- **Bootloader**: 5/5 — Official unlock, no wait period
- **Kernel**: 4/5 — Snapdragon 765G mainline mature (5.10+ LTS), GKI
- **Blobs**: 5/5 — Same Google extraction policy
- **Community**: 5/5 — LineageOS 21 official, very mature, GrapheneOS/CalyxOS
- **Recovery**: 5/5 — Fastboot workflow identical
- **Docs**: 4/5 — Same as 6a/7a
- **Risk**: 5/5 — Same unbrickable profile
- **Note**: End-of-life for Google updates (2024), but excellent for AOSP development

#### SHIFT6mq
- **Bootloader**: 5/5 — Official unlock, no restrictions
- **Kernel**: 5/5 — Mainline-first (Qualcomm SM6375), fully upstreamed
- **Blobs**: 3/5 — Modem/camera firmware proprietary, limited extraction tooling
- **Community**: 2/5 — Very small community, LineageOS unofficial, limited maintainers
- **Recovery**: 3/5 — Fastboot works, no TWRP, EDL untested
- **Docs**: 5/5 — Schematics, repair guides, modular design published
- **Risk**: 4/5 — Modular design helps, but small community means less tested recovery

#### Motorola Edge 40
- **Bootloader**: 4/5 — Official unlock via Motorola website, but requires account + wait
- **Kernel**: 3/5 — MediaTek Dimensity 8020 mainline WIP, Motorola kernel drops slow
- **Blobs**: 3/5 — Extractable but MediaTek blobs more restrictive
- **Community**: 3/5 — LineageOS unofficial, smaller XDA presence
- **Recovery**: 3/5 — Fastboot + blank flash, EDL complex on MediaTek
- **Docs**: 3/5 — Minimal public documentation
- **Risk**: 3/5 — MediaTek EDL requires authorized tools, higher brick risk

#### Xiaomi 13
- **Bootloader**: 3/5 — Unlockable but 7-30 day wait period, Mi Account binding, region locks
- **Kernel**: 3/5 — Snapdragon 8 Gen 2 mainline WIP, Xiaomi kernel source delayed
- **Blobs**: 3/5 — Proprietary camera/modem stack, extraction legal gray area
- **Community**: 4/5 — Large XDA, LineageOS unofficial, many custom ROMs
- **Recovery**: 4/5 — Fastboot + TWRP, EDL available (but locked behind auth)
- **Docs**: 2/5 — No public schematics, kernel source minimal
- **Risk**: 3/5 — EDL requires authorized account, anti-rollback protection

---

## 3. Evaluation Matrix Summary

| Rank | Device | Score | Verdict |
|------|--------|-------|---------|
| 1 | **Google Pixel 7a** | 33/35 | **Primary** — Best overall balance |
| 2 | **Google Pixel 6a** | 33/35 | **Fallback** — Identical score, older SoC |
| 3 | **Google Pixel 5a** | 33/35 | **Budget** — EOL but excellent support |
| 4 | **Fairphone 5** | 32/35 | **Ethical Alt** — Best docs/repairability |
| 5 | **Nothing Phone (2)** | 28/35 | **Viable** — Good but younger ecosystem |
| 6 | **SHIFT6mq** | 27/35 | **Niche** — Mainline ideal, community weak |
| 7 | **OnePlus 11** | 26/35 | **Wait** — Wait period, kernel lag |
| 8 | **Sony Xperia 1 V** | 26/35 | **Docs Leader** — Best docs, unlock friction |

---

## 4. Recommendation

### Primary Choice: **Google Pixel 7a**

**Justification:**
- **Maximum score (33/35)** across all critical criteria
- **Zero friction bootloader unlock** — retail units unlock instantly via fastboot
- **Tensor G2 mainline momentum** — Google actively upstreaming, GKI kernels for 5+ years
- **Largest active community** — LineageOS official, GrapheneOS/CalyxOS reference device
- **Legal blob extraction** — Factory images published, redistribution explicitly permitted
- **Unbrickable** — Fastboot mode always accessible, no EDL/JTAG ever needed
- **Current generation** — 3+ years of Android version support remaining
- **Cost-effective** — ~$350-400 new, ~$250-300 used (excellent condition)

### Fallback Choice: **Google Pixel 6a**

- Identical score (33/35), marginally older Tensor GS101
- Mature kernel tree (6.1 LTS), slightly better mainline coverage today
- Lower cost (~$200-250 used)
- **Trade-off**: Tensor GS101 has known modem stability issues vs G2

### Budget Alternative: **Google Pixel 5a**

- Same 33/35 score, Snapdragon 765G with mature mainline
- **Caveat**: Google security updates ended August 2024 — acceptable for AOSP dev but not production fleet

### Ethical/Sustainability Alternative: **Fairphone 5**

- Highest documentation/repairability score (5/5)
- 5+ year kernel support commitment
- **Trade-off**: Smaller community, QCM6490 mid-range performance, higher cost (~€650)

---

### Procurement Plan

| Device | Condition | Est. Cost | Source | Qty | Timeline |
|--------|-----------|-----------|--------|-----|----------|
| Pixel 7a | New (unlocked) | $380 | Google Store / Best Buy | 2 | 1 week |
| Pixel 7a | Used (excellent) | $280 | Swappa / eBay / Back Market | 3 | 1-2 weeks |
| Pixel 6a | Used (excellent) | $220 | Swappa / eBay | 2 | 1 week |
| **Total** | | **~$1,800** | | **7 devices** | |

**Rationale for 7 devices:**
- 2 primary dev devices (daily driver + test)
- 2 CI runners (self-hosted GitHub Actions)
- 2 stress/test devices (thermal, battery, monkey testing)
- 1 spare (brick replacement, though unlikely)

---

### Timeline to First Build

| Phase | Duration | Milestone |
|-------|----------|-----------|
| **Week 1** | 5 days | Device procurement, bootloader unlock, stock backup |
| **Week 2** | 5 days | Device tree bringup (from LineageOS/Google sources), kernel config |
| **Week 3** | 5 days | Vendor blob extraction, SEPolicy, init scripts |
| **Week 4** | 5 days | First `breakfast` + `mka bacon` — bootable LineageOS-based build |
| **Week 5** | 5 days | Meridian customizations: init, overlays, prebuilts, signing |
| **Week 6** | 5 days | CI pipeline, OTA infrastructure, test matrix |
| **Total** | **~6 weeks** | **First signed Meridian OS build for Pixel 7a** |

---

## 5. Android Build Infrastructure

### Hardware Requirements (Per Build Machine)

| Component | Minimum | Recommended | Notes |
|-----------|---------|-------------|-------|
| **Storage** | 200 GB | 500 GB NVMe | Source ~100GB, out/ ~150GB, ccache ~50GB |
| **RAM** | 32 GB | 64 GB | 16GB fails on clang/linking; 32GB bare minimum |
| **CPU Cores** | 16 | 32+ | `make -j$(nproc)` — more cores = linear speedup |
| **Network** | 1 Gbps | 10 Gbps | Source sync ~50GB, CI artifact upload |

**Recommended Build Server Spec:**
- AMD EPYC 7543P (32c/64t) or Ryzen 9 7950X (16c/32t)
- 64 GB DDR5-5600 ECC
- 2 TB NVMe (OS) + 4 TB NVMe (builds/ccache)
- Ubuntu 22.04 LTS / 24.04 LTS

### CI/CD Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                  GitHub Actions (Self-Hosted)               │
├─────────────────────────────────────────────────────────────┤
│  Trigger: Push to main, PR, scheduled nightly, tag          │
│                                                             │
│  Jobs:                                                       │
│  ├─ sync-sources      → repo sync (partial, shallow)        │
│  ├─ build-kernel      → GKI + device modules                │
│  ├─ build-rom         → mka bacon (incremental + ccache)    │
│  ├─ test-boot         → fastboot flash + automated boot test│
│  ├─ sign-build        → test keys → release keys (later)    │
│  ├─ generate-ota      → payload.bin + metadata              │
│  └─ publish           → GH Release / OTA server / artifacts │
└─────────────────────────────────────────────────────────────┘
```

**Self-Hosted Runner Advantages:**
- Persistent `ccache` (massive speedup on incremental builds)
- Bazel remote cache (if migrating to Soong/Bazel hybrid)
- Hardware access for hardware-backed tests
- No GitHub Actions minute limits / queue times

### Caching Strategy

| Cache Layer | Tool | Scope | Retention |
|-------------|------|-------|-----------|
| **Compiler** | `ccache` | C/C++/Rust/Clang | Persistent (prune 90d) |
| **Java** | `gradle`/`soong` cache | Jack/D8/R8 | Per-build |
| **Bazel** | Remote cache (gRPC) | Actions/artifacts | 30 days |
| **Repo** | `git` shallow + manifest pin | Source tree | N/A |
| **Docker** | Layer cache | Build containers | CI only |

**ccache Config:**
```bash
# ~/.ccache/ccache.conf
max_size = 50G
compression = true
compression_level = 6
hash_dir = false
sloppiness = pch_defines,time_macros,include_file_mtime,include_file_ctime
```

### Manifest Repository: `conexus-rom`

**To Create:** `github.com/conexus-systems/conexus-rom`

```
conexus-rom/
├── default.xml              # Main manifest (LineageOS base + Meridian customizations)
├── conexus.xml              # Meridian-specific projects
├── local_manifests/         # Device/kernel/vendor overrides (gitignored)
│   ├── pixel7a.xml          # Device tree, kernel, vendor for Pixel 7a
│   ├── pixel6a.xml          # Fallback device
│   └── fairphone5.xml       # Ethical alternative
├── signing-keys/            # Test keys (generated), release keys (encrypted)
├── build-targets/           # Build target definitions (brunch/lunch combos)
├── ota/                     # OTA metadata generation scripts
├── ci/                      # GitHub Actions workflows
├── docker/                  # Build container definitions
└── docs/                    # Build documentation
```

**default.xml Base:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <!-- LineageOS 21 (Android 14) base -->
  <remote name="los" fetch="https://github.com/LineageOS" />
  <remote name="aosp" fetch="https://android.googlesource.com" />
  <remote name="google" fetch="https://android.googlesource.com/device/google" />
  <remote name="conexus" fetch="https://github.com/conexus-systems" />

  <default revision="lineage-21" remote="los" sync-j="8" />

  <!-- Core LineageOS -->
  <project path="build/soong" name="build_soong" />
  <project path="build/make" name="build_make" />
  <project path="frameworks/base" name="frameworks_base" />
  <!-- ... all standard LineageOS projects ... -->

  <!-- Meridian Customizations -->
  <project path="vendor/conexus" name="vendor_conexus" remote="conexus" />
  <project path="packages/apps/MeridianSettings" name="packages_apps_MeridianSettings" remote="conexus" />
  <project path="packages/apps/MeridianUpdater" name="packages_apps_MeridianUpdater" remote="conexus" />

  <!-- Device-specific (included via local_manifests) -->
  <!-- <include name="local_manifests/pixel7a.xml" /> -->
</manifest>
```

### Local Manifests for Device/Kernel/Vendor

**local_manifests/pixel7a.xml:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <!-- Device Tree -->
  <project path="device/google/lynx" name="device_google_lynx" remote="los" revision="lineage-21" />
  <project path="device/google/gs201" name="device_google_gs201" remote="los" revision="lineage-21" />

  <!-- Kernel (GKI + device modules) -->
  <project path="kernel/google/gs201" name="kernel_google_gs201" remote="los" revision="lineage-21" />
  <project path="kernel/google/gs201/techpack/audio" name="kernel_google_gs201-techpack_audio" remote="los" revision="lineage-21" />
  <project path="kernel/google/gs201/techpack/camera" name="kernel_google_gs201-techpack_camera" remote="los" revision="lineage-21" />
  <project path="kernel/google/gs201/techpack/display" name="kernel_google_gs201-techpack_display" remote="los" revision="lineage-21" />
  <project path="kernel/google/gs201/techpack/video" name="kernel_google_gs201-techpack_video" remote="los" revision="lineage-21" />

  <!-- Vendor Blobs (extracted from factory images) -->
  <project path="vendor/google/lynx" name="vendor_google_lynx" remote="conexus" revision="main" />
  <project path="vendor/google/gs201" name="vendor_google_gs201" remote="conexus" revision="main" />

  <!-- Hardware Interfaces (HALs) -->
  <project path="hardware/google/pixel" name="hardware_google_pixel" remote="los" revision="lineage-21" />
  <project path="hardware/google/camera" name="hardware_google_camera" remote="los" revision="lineage-21" />
</manifest>
```

---

## 6. First Target Worktree Plan

### Directory Structure

```
work/android/
├── pixel7a/                          # Primary device worktree
│   ├── device/
│   │   └── google/
│   │       ├── lynx/                 # Device tree (lynx = Pixel 7a codename)
│   │       │   ├── Android.bp
│   │       │   ├── BoardConfig.mk
│   │       │   ├── init/
│   │       │   ├── overlay/
│   │       │   ├── sepolicy/
│   │       │   ├── lineage_lynx.mk
│   │       │   └── meridium_lynx.mk  # Meridian variant
│   │       └── gs201/                # SoC common (Tensor G2)
│   ├── kernel/
│   │   └── google/
│   │       └── gs201/                # GKI kernel + modules
│   ├── vendor/
│   │   └── google/
│   │       ├── lynx/                 # Device blobs
│   │       └── gs201/                # SoC blobs
│   ├── hardware/
│   │   └── google/
│   │       ├── pixel/                # Pixel HALs
│   │       └── camera/               # Camera HAL
│   └── README.md
│
├── pixel6a/                          # Fallback device worktree (same structure)
│   └── ...
│
├── fairphone5/                       # Ethical alternative worktree
│   └── ...
│
├── build/
│   ├── meridian-pixel7a.yml          # KAS-equivalent build config
│   ├── meridian-pixel6a.yml
│   └── meridian-fairphone5.yml
│
└── signing-keys/
    ├── test/                         # Generated test keys (checked in)
    │   ├── releasekey.pk8
    │   ├── releasekey.x509.pem
    │   ├── platform.pk8
    │   ├── platform.x509.pem
    │   ├── shared.pk8
    │   ├── shared.x509.pem
    │   ├── media.pk8
    │   ├── media.x509.pem
    │   ├── networkstack.pk8
    │   └── networkstack.x509.pem
    └── release/                      # Production keys (encrypted, not in git)
        └── .gitignore
```

### Build Configuration: `build/meridian-pixel7a.yml`

```yaml
# KAS-equivalent for Android (inspired by KAS but for Soong/Lineage)
# Used by build script: ./build.sh meridian-pixel7a

build:
  target: "meridian_lynx-userdebug"
  device: "lynx"
  variant: "userdebug"  # userdebug for dev, user for release

  # LineageOS base
  lineage_version: "21"
  android_version: "14"
  security_patch: "2025-01-05"

  # Meridian customizations
  meridian:
    version: "1.0.0"
    codename: "equinox"
    maintainer: "Conexus Systems"
    website: "https://conexus.systems"
    donations: "https://github.com/sponsors/conexus-systems"

  # Build optimization
  optimization:
    ccache: true
    ccache_size: "50G"
    jobs: "auto"  # $(nproc)
    use_bazel: false  # Soong only for now
    clang_version: "r487747c"  # Prebuilt from AOSP
    lld: true
    thin_lto: true

  # Signing
  signing:
    test_keys: true
    keys_dir: "work/android/signing-keys/test"
    # release_keys_dir: "work/android/signing-keys/release"  # For production

  # Output
  output:
    dir: "out/meridian/pixel7a"
    target_files: true
    ota_package: true
    factory_images: false  # Enable for release
    json_metadata: true

  # Prebuilts / Overlays
  prebuilts:
    - "vendor/conexus/prebuilts/common"
    - "vendor/conexus/prebuilts/pixel7a"

  # SEPolicy
  sepolicy:
    dir: "device/google/lynx/sepolicy"
    dynamic: true

  # Kernel
  kernel:
    source: "kernel/google/gs201"
    defconfig: "gki_defconfig vendor/gs201/lynx.config"
    gki: true
    modules:
      - "audio"
      - "camera"
      - "display"
      - "video"

  # Vendor Blobs
  vendor:
    extract_script: "vendor/google/lynx/extract-files.sh"
    source: "factory-image"  # or "ota"
    verify_checksums: true
```

### Build Script Wrapper: `build.sh`

```bash
#!/usr/bin/env bash
# build.sh — Meridian OS Android build wrapper
# Usage: ./build.sh meridian-pixel7a

set -euo pipefail

CONFIG="${1:-meridian-pixel7a}"
CONFIG_FILE="build/${CONFIG}.yml"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config not found: $CONFIG_FILE"
    exit 1
fi

# Parse YAML (using yq)
TARGET=$(yq -r '.build.target' "$CONFIG_FILE")
DEVICE=$(yq -r '.build.device' "$CONFIG_FILE")
JOBS=$(yq -r '.build.optimization.jobs' "$CONFIG_FILE")
CCACHE_SIZE=$(yq -r '.build.optimization.ccache_size' "$CONFIG_FILE")

# Setup environment
export CCACHE_DIR="${HOME}/.ccache/meridian"
export CCACHE_MAXSIZE="$CCACHE_SIZE"
export USE_CCACHE=1
export ANDROID_JACK_VM_ARGS="-Xmx8g -Dfile.encoding=UTF-8 -XX:+TieredCompilation"

# Source build environment
source build/envsetup.sh

# Lunch target
lunch "$TARGET"

# Build
mka bacon -j"${JOBS:-$(nproc)}" 2>&1 | tee "build_${DEVICE}_$(date +%Y%m%d_%H%M%S).log"

# Post-build
if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
    echo "Build successful!"
    # Sign, package OTA, etc.
    ./sign_and_package.sh "$CONFIG"
else
    echo "Build failed!"
    exit 1
fi
```

### Signing Keys Generation (Test Keys First)

```bash
#!/usr/bin/env bash
# generate-test-keys.sh — Run once per worktree

set -euo pipefail

KEYS_DIR="work/android/signing-keys/test"
mkdir -p "$KEYS_DIR"

SUBJECT="/C=BR/ST=SP/L=Sao Paulo/O=Conexus Systems/OU=Meridian OS/CN=Meridian Test Key"
PASSWORD="meridian-test"  # Test keys only — no security concern

for key in releasekey platform shared media networkstack; do
    echo "Generating $key..."
    openssl genrsa -3 -out "$KEYS_DIR/$key.pk8" 2048 2>/dev/null
    openssl req -new -x509 -key "$KEYS_DIR/$key.pk8" -out "$KEYS_DIR/$key.x509.pem" \
        -days 10000 -subj "$SUBJECT" -passin pass:"$PASSWORD"
    # Convert to PKCS#8 for Android
    openssl pkcs8 -in "$KEYS_DIR/$key.pk8" -topk8 -outform DER -out "$KEYS_DIR/$key.pk8" -nocrypt
done

# Verify
for key in releasekey platform shared media networkstack; do
    echo "Verifying $key..."
    openssl x509 -in "$KEYS_DIR/$key.x509.pem" -text -noout | head -20
done

echo "Test keys generated in $KEYS_DIR"
echo "IMPORTANT: These are TEST KEYS only. Do not use for production releases."
```

**Release Keys (Production):**
- Generated offline on air-gapped machine
- Stored in HashiCorp Vault / AWS KMS / GCP KMS
- Never checked into git
- Rotated annually
- `signapk.jar` with release keys for final OTA signing

---

## Appendix: Quick Reference Commands

```bash
# Initial setup
mkdir -p work/android && cd work/android
repo init -u https://github.com/conexus-systems/conexus-rom -b main
# Copy local_manifests/pixel7a.xml → .repo/local_manifests/
repo sync -j16 -c --no-tags

# Device bringup
cd device/google/lynx
# Edit BoardConfig.mk, init, sepolicy, overlays

# Extract vendor blobs (from factory image)
cd vendor/google/lynx
./extract-files.sh ~/factory-images/lynx-factory-image.zip

# First build
cd /path/to/work/android
source build/envsetup.sh
lunch meridian_lynx-userdebug
mka bacon -j32

# Flash to device
fastboot flashall -w  # -w wipes data

# Generate OTA
./build/make/tools/releasetools/ota_from_target_files \
    -k signing-keys/test/releasekey \
    out/meridian/pixel7a/meridian_lynx-target_files-*.zip \
    out/meridian/pixel7a/meridian_lynx-ota-$(date +%Y%m%d).zip
```

---

## Decision Log

| Date | Decision | Author | Rationale |
|------|----------|--------|-----------|
| 2026-10-30 | Pixel 7a as primary target | Orquestrador | Highest score, zero unlock friction, active upstream, unbrickable |
| 2026-10-30 | Pixel 6a as fallback | Orquestrador | Identical score, lower cost, mature kernel |
| 2026-10-30 | Fairphone 5 as ethical alt | Orquestrador | Best documentation, repairability, sustainability alignment |
| 2026-10-30 | Self-hosted CI required | Orquestrador | ccache persistence critical for Android build times |
| 2026-10-30 | Test keys first, release keys later | Orquestrador | Security: release keys never in CI/git; offline generation |

---

*Document version: 1.0*  
*Created: 2026-10-30*  
*Next review: After first successful build (Week 4)*