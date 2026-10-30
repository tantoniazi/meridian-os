# Lumia 730 (MSM8226) Boot/Kernel Research Plan

> **Target**: Nokia Lumia 730 (RM-1017/1018/1019/1020) — Qualcomm MSM8226 (Snapdragon 400)
> **Branch**: `research/lumia730-boot`
> **Worktree**: `/home/tiagoadg/Codes/tantoniazi/meridian-os/work/research/lumia730`

---

## 1. Device Identification

| Property | Value |
|----------|-------|
| **Commercial Name** | Nokia Lumia 730 |
| **Codename** | `superman` / `msm8226` |
| **SoC** | Qualcomm **MSM8226** (Snapdragon 400) — **NOT MSM8926 (Lumia 735)** |
| **Variants** | RM-1017 (single SIM), RM-1018 (dual SIM), RM-1019, RM-1020 |
| **RAM** | 1 GB LPDDR3 |
| **Storage** | 8 GB eMMC 4.5 |
| **Display** | 4.7" 720×1280 OLED (MIPI DSI), 316 ppi |
| **Product Codes** | 059Wxx, 059Wxy (varies by region/carrier) |
| **Launch OS** | Windows Phone 8.1 (upgradable to Windows 10 Mobile) |

### Key Distinction: Lumia 730 vs 735
- **Lumia 730 (MSM8226)**: 3G only, dual SIM variants exist
- **Lumia 735 (MSM8926)**: LTE, different modem, **not compatible** with this research

---

## 2. Boot Chain Analysis

### Bootloader Stages
```
PBL (Primary Boot Loader, ROM)
    ↓
SBL1 (Secondary Boot Loader 1) — eMMC boot partition 0 (boot0)
    ↓
SBL2 / SBL3
    ↓
TZ (TrustZone / TEE) — partition: tz
    ↓
RPM (Resource Power Manager) — partition: rpm
    ↓
ABL (Apps Bootloader / aboot) — partition: aboot
    ↓
Linux Kernel + DTB + initramfs
```

### eMMC Partition Map (Boot Partitions)
| Partition | Name | Purpose | Size (typical) |
|-----------|------|---------|----------------|
| `boot0` | `sbl1` | SBL1 (primary) | 4 MB |
| `boot1` | `sbl1_backup` | SBL1 (backup) | 4 MB |
| `rpm` | `rpm` | Resource Power Manager | 1–2 MB |
| `tz` | `tz` | TrustZone / TEE | 2–4 MB |
| `aboot` | `aboot` | Apps Bootloader (LK-based) | 1–2 MB |
| `modem` | `NON-HLOS` | Modem firmware | 60–80 MB |
| `dtb` | `dtb` | Device Tree Blob | 1 MB |
| `boot` | `boot` | Kernel + ramdisk (WP) | 20–30 MB |
| `recovery` | `recovery` | Recovery kernel | 20–30 MB |

### Locked Bootloader
- **Official unlock**: ❌ Never provided by Nokia/Microsoft
- **Bootloader state**: Locked (verifies signatures on aboot → kernel)
- **Implication**: Must use **EDL Mode** or exploit to flash unsigned images

---

## 3. Unlock Methods

### 3.1 EDL Mode (Emergency Download) — Primary Path
- **Access**: Short test points on PCB (requires full disassembly)
- **Test Points**: Typically labeled `TP_E1`, `TP_E2` or similar near eMMC
- **Tool**: QFIL (Qualcomm Flash Image Loader) via USB
- **Risk**: **HARD BRICK POSSIBLE** — no JTAG on MSM8226 Lumia

#### Test Point Identification (TODO: Document with Photos)
- [ ] Disassemble device, locate test points on mainboard
- [ ] Verify EDL entry: `lsusb` shows `05c6:9008 Qualcomm, Inc. Gobi Wireless Modem (QDL mode)`
- [ ] Document pinout with photos for recovery

### 3.2 QFIL Flashing
- **Files needed**: `prog_emmc_firehose_8916.mbn`, `rawprogram_unsparse.xml`, `patch.xml`
- **Source**: Extracted from official firmware (see §5)
- **Caution**: Flashing wrong partition = brick

### 3.3 Known Exploits / Community Projects
| Project | Status | Notes |
|---------|--------|-------|
| **LumiaWOA** | Active | Windows on ARM for Lumia 950/950 XL; limited 730 support |
| **Mainline4Lumia** | Active | Mainline Linux for Lumia devices; check 730 DT |
| **WinPhone8Boot** | Archived | Early boot research, chainloader approach |
| **Renegade Project** | Active | Custom aboot unlock for some Lumias |

**Action**: Survey each for MSM8226-specific progress.

---

## 4. Mainline Linux Status (MSM8226)

### Device Tree Sources
| File | Path in Mainline | Status |
|------|------------------|--------|
| SoC DT | `arch/arm64/boot/dts/qcom/msm8226.dtsi` | ✅ Exists |
| Board DT | `arch/arm64/boot/dts/qcom/msm8226-lumia730.dts` | 🔍 **CHECK IF EXISTS** |
| PMIC DT | `arch/arm64/boot/dts/qcom/pm8941.dtsi` | ✅ Exists |

### Driver Support Matrix
| Subsystem | Driver | Status | Notes |
|-----------|--------|--------|-------|
| **Display** | MDSS (MIPI DSI) | 🟡 Partial | Panel driver for 720p OLED needed; check `panel-simple` or custom |
| **Touch** | Synaptics RMI4 / Atmel MXT | 🔍 Unknown | Identify controller via `dmesg` on stock WP |
| **Audio** | WCD9320 / WCD9330 | 🟡 WIP | `sound/soc/qcom/wcd9335.c` exists; DT bindings needed |
| **PMIC** | PM8941 | ✅ Mainline | `drivers/mfd/pm8xxx.c`, regulators, GPIOs |
| **Modem** | QRTR/QMI + `qrtr-mhi` | ✅ Mainline | **Firmware required** (NON-HLOS); load via `firmware_class` |
| **WiFi** | WCN3660 / QCA6174 | ✅ ath10k/ath11k | Firmware in `linux-firmware` (`ath10k/QCA6174/`) |
| **Bluetooth** | WCN3660 (BT) | ✅ btqca | Requires `qca` firmware + `hci_uart` |
| **Storage** | eMMC (sdhci-msm) | ✅ Mainline | Boot partitions accessible via `mmcblk0boot0/1` |
| **USB** | DWC3 (Peripheral + Host) | ✅ Mainline | OTG support; check `usb_phy` |
| **GPU** | Adreno 305 (a3xx) | ✅ freedreno | `MSM_KMS` + `drm/kms`; needs `a3xx` firmware |
| **Sensors** | Accel/Gyro/Prox/ALS | 🔍 Unknown | Likely I2C; identify models |
| **Camera** | OV8865 (rear), OV2680 (front) | 🔍 Unknown | V4L2 + media controller; check ISP support |

### Kernel Config Requirements
```bash
# Minimum defconfig fragments for MSM8226
CONFIG_ARCH_MSM8226=y
CONFIG_MACH_LUMIA730=y
CONFIG_QCOM_MSM8226_PM=y
CONFIG_QCOM_PM8941=y
CONFIG_DRM_MSM=y
CONFIG_DRM_MSM_KMS=y
CONFIG_DRM_FREEDRENO=y
CONFIG_MSM_KMS=y
CONFIG_USB_DWC3=y
CONFIG_MMC_SDHCI_MSM=y
CONFIG_SND_SOC_WCD9335=y
CONFIG_BT_QCA=y
CONFIG_ATH10K=y
```

---

## 5. Firmware / Blobs

### Required Proprietary Blobs
| Blob | Partition | Source | Notes |
|------|-----------|--------|-------|
| `NON-HLOS.bin` | `modem` | Official firmware | Modem firmware (MBN format) |
| `tz.mbn` | `tz` | Official firmware | TrustZone |
| `rpm.mbn` | `rpm` | Official firmware | RPM |
| `sbl1.mbn` | `sbl1` | Official firmware | SBL1 |
| `aboot.mbn` | `aboot` | Official firmware | Apps bootloader |
| `dtb.img` | `dtb` | Build from DT | Device tree blob |
| `modem_fw/*` | `/lib/firmware/` | Official firmware | QCA/WCN firmware for WiFi/BT |
| `adreno/*` | `/lib/firmware/` | `linux-firmware` | GPU firmware (a3xx) |

### Extraction Procedure
1. Download official firmware via **NaviFirm** or **Nokia Care Suite**
   - Product codes: `059Wxxx` (varies by region)
   - File: `.ffu` (Windows Phone) or `.mbn` archive
2. Use `ffu_extract` or `thor2` to unpack FFU
3. Locate MBN files in `Image/` subdirectories
4. **Legal Warning**: Redistribution of Nokia/Microsoft firmware blobs is **legally unclear**. Document source, do not publish blobs.

---

## 6. Recovery Plan

### Pre-Flight: Full eMMC Backup (MANDATORY)
```bash
# In EDL mode via QFIL
# 1. Identify all partitions via `sgdisk -p /dev/sdX` or QFIL partition XML
# 2. Dump each partition:
dd if=/dev/sdX of=backup_sbl1.mbn bs=512 count=8192      # boot0 (4 MB)
dd if=/dev/sdX of=backup_sbl1_bak.mbn bs=512 count=8192  # boot1
dd if=/dev/sdX of=backup_rpm.mbn bs=512 count=4096       # rpm
dd if=/dev/sdX of=backup_tz.mbn bs=512 count=8192        # tz
dd if=/dev/sdX of=backup_aboot.mbn bs=512 count=4096     # aboot
dd if=/dev/sdX of=backup_modem.mbn bs=512 count=163840   # modem (~80 MB)
# ... etc for all partitions
```

### Restore Procedure
1. Enter EDL mode (test points)
2. QFIL → Load `rawprogram_unsparse.xml` from backup
3. Flash all partitions
4. Verify boot to Windows Phone

### Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Hard brick (bad aboot/tz/rpm) | Medium | **Device dead** | Full backup first; verify EDL works |
| Soft brick (bad kernel/dtb) | High | Bootloop | Keep stock `boot` partition; dual-boot via aboot |
| Modem non-functional | High | No calls/data | Test firmware loading early |
| Display blank | Medium | No visual feedback | Serial console (UART) mandatory |

### UART / Serial Console
- **Location**: Typically on test pads near SIM tray or battery connector
- **Baud**: 115200 8N1
- **Voltage**: 1.8V (MSM8226) — **use level shifter**
- **Pinout**: TX, RX, GND (verify with multimeter)

---

## 7. Gate Criteria (per Conexus ADR-003)

> **Rule**: No Android/Linux port proposal until ALL gates pass.

| # | Gate | Criteria | Status | Evidence Required |
|---|------|----------|--------|-------------------|
| 1 | **Boot Chain Documented** | Complete partition map + boot flow diagram | ☐ | `docs/lumia730-bootchain.md` |
| 2 | **EDL Mode Verified** | Test points identified, `05c6:9008` enumerates | ☐ | Photos + `lsusb` output |
| 3 | **Mainline Kernel Boots** | Reaches `initramfs` / serial console prompt | ☐ | `dmesg` log + photo |
| 4 | **Display + Touch** | Framebuffer visible, touch events in `/dev/input` | ☐ | Photo + `evtest` output |
| 5 | **Storage (eMMC) R/W** | Can mount userdata, read/write files | ☐ | `mount` + `dd` test |
| 6 | **Modem Firmware Loads** | `qrtr` + `qmi` enumerate modem, SIM detected | ☐ | `mmcli -L` or `qmicli` |
| 7 | **Recovery Tested** | Restored from backup via EDL, boots stock WP | ☐ | Video or photo sequence |
| 8 | **Port Proposal** | Only after Gates 1–7 ✅ | ☐ | `docs/lumia730-port-proposal.md` |

---

## 8. Next Steps (Immediate)

1. [ ] **Acquire device** (RM-1017 or RM-1018 preferred)
2. [ ] **Download official firmware** via NaviFirm (product code 059Wxxx)
3. [ ] **Disassemble & document test points** (photos, pinout)
4. [ ] **Enter EDL mode** → verify `lsusb` shows `05c6:9008`
5. [ ] **Full eMMC backup** via QFIL
6. [ ] **Extract blobs** (NON-HLOS, tz, rpm, sbl1, aboot)
7. [ ] **Check mainline DT**: `git log --oneline -- arch/arm64/boot/dts/qcom/msm8226*`
8. [ ] **Build minimal kernel** with MSM8226 defconfig + serial console
9. [ ] **Flash test kernel** to `boot` partition via EDL
10. [ ] **Capture serial log** → iterate

---

## 9. References & Resources

- **Mainline DT**: <https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/boot/dts/qcom/msm8226.dtsi>
- **Freedreno Docs**: <https://docs.mesa3d.org/drivers/freedreno.html>
- **QCOM Mainline Porting**: <https://github.com/linaro-swg/qualcomm-linux>
- **LumiaWOA**: <https://github.com/WOA-Project/LumiaWOA>
- **Mainline4Lumia**: <https://github.com/mainline4lumia>
- **EDL Test Points (generic)**: <https://forum.xda-developers.com/t/guide-edl-mode-test-points.3920421/>
- **FFU Extract**: <https://github.com/Thor2002/ffu_extract>
- **NaviFirm**: <https://navifirm.com/> (or `navifirm-cli`)

---

## 10. Commit Record

> **Commit**: `docs: add Lumia 730 (MSM8226) boot/kernel research plan`
> **Branch**: `research/lumia730-boot`
> **Author**: Research subagent
> **Date**: 2026-10-30

---

*This document is a living plan. Update gates as evidence is collected. Do not proceed to port proposal until Gate 7 passes.*