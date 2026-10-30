# Meridian OS - Device Support Matrix

> **Source of truth**: This matrix is populated from verifiable evidence in the Meridian OS codebase (kernel configs, KAS build files, Phase 1 hwinit scripts, build scripts). Fields marked "A confirmar - requer validação física" lack physical hardware validation.

---

## Legend

| Classification | Meaning |
|----------------|---------|
| **SUPPORTED** | Full build pipeline works; kernel + userspace + hwinit validated in CI; OSTree images boot |
| **EXPERIMENTAL** | Kernel config + hwinit exist; no complete KAS build in `device-matrix/`; requires hardware validation |
| **RESEARCH** | Only placeholder configs exist; boot chain / drivers / recovery unproven |
| **BLOCKED** | Fundamental blockers (no infra, no device trees, no vendor blobs) |

---

## 1. Nokia N900 (RX-51)

| Field | Value | Evidence |
|-------|-------|----------|
| **Fabricante** | Nokia | |
| **Nome comercial** | N900 | |
| **Codename** | RX-51 | |
| **Variante** | Phone | `build/meridian-n900.yml:18` `target: phone-n900` |
| **SoC** | TI OMAP3430 (Cortex-A8 @ 600 MHz) | `kernel/configs/meridian-omap3_defconfig:4,8` `CONFIG_SOC_OMAP3430=y` |
| **RAM** | 256 MB | A confirmar - requer validação física |
| **Armazenamento** | 32 GB eMMC | A confirmar - requer validação física |
| **Revisão de placa** | A confirmar - requer validação física | |
| **Bootloader** | U-Boot (`u-boot-meridian-n900`) + MLO (X-Loader) | `build/meridian-n900.yml:72` `scripts/build_phase0.sh:100-101` |
| **Método de desbloqueio conhecido** | Maemo flasher, open mode (no signature enforcement) | A confirmar - requer validação física |
| **Versão atual firmware/OS** | Meridian OS (Debian trixie + OSTree, kernel 6.6 LTS) | `build/meridian-n900.yml:9` `branches: [trixie]` |
| **Kernel source** | `linux-image-meridian-omap3` (mainline 6.6 + `kernel/patches/omap3/series`) | `kernel/patches/omap3/series` (30 patches) |
| **Device tree / ACPI** | `omap3-n900.dtb` (patch `0028-omap3-n900-dts`) | `kernel/patches/omap3/series:37` |
| **DT Overlays** | `n900-keyboard`, `n900-tvout` | `scripts/build_phase0.sh:112` |
| **Vendor blobs** | `firmware-ti-connectivity` (WL1271), `linux-firmware` | `build/meridian-n900.yml:70-71` |
| **Display** | 800×480 resistive (TPS65950), TV-out composite (DAC) | `phase1/n900/hwinit.sh:55-58,115-126` |
| **Touch** | TPS65950 touchscreen (`tps65950_ts`, `tsc2007`) | `phase1/n900/hwinit.sh:70-72` |
| **Áudio** | TPS65950 + TWL4030 codecs (`snd_soc_tps65950`, `snd_soc_twl4030`) | `phase1/n900/hwinit.sh:206-208` `kernel/configs/...:32-33` |
| **Câmera** | MT9T111 5 MP rear (`mt9t111`, `omap3_camera`) | `phase1/n900/hwinit.sh:159-160` `kernel/patches/...:16` |
| **Wi-Fi** | WL1271 (TI connectivity, SDIO) | `kernel/patches/omap3/series:30` `build/meridian-n900.yml:70` |
| **Bluetooth** | WL1271 (shared with Wi-Fi) | `build/meridian-n900.yml:48` `bluez` package |
| **Modem** | HSI interface (`hsi_char`, `ti_hsi`), ofono + ModemManager | `phase1/n900/hwinit.sh:177-181` `kernel/configs/...:16-18` |
| **Sensores** | LIS331 (accel), HMC5843 (mag), L3G4200D (gyro) | `phase1/n900/hwinit.sh:226-233` `kernel/configs/...:22-24` |
| **Bateria / Carga** | TPS65950 PMIC (regulators vaux1-4, vmmc1-2, vdac, vio, vpll, vdd1-2, vusb) | `phase1/n900/hwinit.sh:35-44` `kernel/configs/...:41-43` |
| **Suspensão** | PM suspend to mem (`echo mem > /sys/power/state`) | `phase1/n900/hwinit.sh:267` |
| **Build reproduzível** | **Sim** — KAS (`build/meridian-n900.yml`), OSTree commit `meridian/phone-n900` | `build/meridian-n900.yml:131-140` `scripts/build_phase0.sh:59-64` |
| **Logs de build** | `build/output/kernel/omap3/`, `build/output/u-boot/n900/` | `scripts/build_phase0.sh:153-154` |
| **Commits relevantes** | Kernel patches 0001–0030, U-Boot n900 config | `kernel/patches/omap3/series` |
| **Testes físicos** | A confirmar - requer validação física | |
| **Classificação** | **SUPPORTED** | Kernel config + KAS build + hwinit complete |
| **Plano de recuperação** | Flash SD card com `meridian-n900-sd.img` (U-Boot + kernel + OSTree repo) | `scripts/build_phase0.sh:70-131` |
| **Riscos de perda de dados** | eMMC overwrite se flasher errado; backup partição `/home` antes | |

---

## 2. Nokia N9 (RM-696 "Lankku")

| Field | Value | Evidence |
|-------|-------|----------|
| **Fabricante** | Nokia | |
| **Nome comercial** | N9 | |
| **Codename** | RM-696 (Lankku) | |
| **Variante** | Phone | `build/meridian-n9.yml:18` `target: phone-n9` |
| **SoC** | TI OMAP3630 (Cortex-A8 @ 1 GHz) | `phase1/n9/hwinit.sh:26` `grep -q "OMAP3630"` |
| **RAM** | 1 GB | A confirmar - requer validação física |
| **Armazenamento** | 16 / 64 GB eMMC | A confirmar - requer validação física |
| **Revisão de placa** | A confirmar - requer validação física | |
| **Bootloader** | U-Boot (`u-boot-meridian-n9`) | `build/meridian-n9.yml:72` |
| **Método de desbloqueio conhecido** | Open mode, flasher (Nokia N9 developer mode) | A confirmar - requer validação física |
| **Versão atual firmware/OS** | Meridian OS (Debian trixie + OSTree, kernel 6.6 LTS) | `build/meridian-n9.yml:9` |
| **Kernel source** | `linux-image-meridian-omap3` (shared with N900) | `build/meridian-n9.yml:26` |
| **Device tree / ACPI** | `omap3-n9.dtb` (patch `0028-omap3-n9-dts`) | `kernel/patches/omap3/series:38` |
| **DT Overlays** | A confirmar - requer validação física | |
| **Vendor blobs** | `firmware-ti-connectivity` (WL1271), `linux-firmware` | `build/meridian-n9.yml:70-71` |
| **Display** | 854×480 AMOLED (Synaptics touch) | `phase1/n9/hwinit.sh:56-58` |
| **Touch** | Synaptics (`synaptics_i2c`, `synaptics_rmi4`) + firmware | `phase1/n9/hwinit.sh:72-78` |
| **Áudio** | TPS65950 + TWL4030 (`snd_soc_tps65950`, `snd_soc_twl4030`) | `phase1/n9/hwinit.sh:194-196` |
| **Câmera** | MT9T112 8 MP rear (`mt9t112`, `omap3_camera`) | `phase1/n9/hwinit.sh:141-142` `kernel/patches/...:17` |
| **Wi-Fi** | WL1271 (TI connectivity) | `phase1/n9/hwinit.sh:237-240` |
| **Bluetooth** | WL1271 + `btusb`, `btrtl`, `btintel` | `phase1/n9/hwinit.sh:243-245` |
| **Modem** | USB CDC/ACM + QRTR (`option`, `qmi_wwan`, `cdc_acm`, `cdc_wdm`) | `phase1/n9/hwinit.sh:159-163` |
| **Sensores** | LIS331, HMC5843, L3G4200D, GP2A (proximity/ALS) | `phase1/n9/hwinit.sh:213-224` |
| **Bateria / Carga** | TPS65950 PMIC (shared regulators with N900) | `phase1/n9/hwinit.sh:40-44` |
| **Suspensão** | PM suspend to mem | `phase1/n9/hwinit.sh:266` |
| **Build reproduzível** | **Sim** — KAS (`build/meridian-n9.yml`), OSTree commit `meridian/phone-n9` | `build/meridian-n9.yml:130-139` |
| **Logs de build** | `build/output/kernel/omap3/`, `build/output/u-boot/n9/` | `scripts/build_phase0.sh:154` |
| **Commits relevantes** | Kernel patches 0001–0030 (N9/N950 DTs) | `kernel/patches/omap3/series:38-39` |
| **Testes físicos** | A confirmar - requer validação física | |
| **Classificação** | **SUPPORTED** | Kernel config + KAS build + hwinit complete |
| **Plano de recuperação** | Mesmo fluxo N900 (SD card com U-Boot + OSTree) | |
| **Riscos de perda de dados** | eMMC overwrite; partição `/home` separada no OSTree deploy | |

---

## 3. Nokia N950 (RM-680)

| Field | Value | Evidence |
|-------|-------|----------|
| **Fabricante** | Nokia | |
| **Nome comercial** | N950 | |
| **Codename** | RM-680 | |
| **Variante** | Developer device (hardware keyboard) | |
| **SoC** | TI OMAP3630 (Cortex-A8 @ 1 GHz) | Same as N9 |
| **RAM** | 1 GB | A confirmar - requer validação física |
| **Armazenamento** | 64 GB eMMC | A confirmar - requer validação física |
| **Revisão de placa** | A confirmar - requer validação física | |
| **Bootloader** | U-Boot (`u-boot-meridian-n9`, same as N9) | `build/meridian-n9.yml:72` |
| **Método de desbloqueio conhecido** | Open mode (developer device) | A confirmar - requer validação física |
| **Versão atual firmware/OS** | Meridian OS (shared N9 build) | |
| **Kernel source** | `linux-image-meridian-omap3` | |
| **Device tree / ACPI** | `omap3-n950.dtb` (patch `0028-omap3-n950-dts`) | `kernel/patches/omap3/series:39` |
| **Vendor blobs** | Same as N9 | |
| **Display** | 854×480 AMOLED | Same as N9 |
| **Touch** | Synaptics | Same as N9 |
| **Teclado** | Hardware keyboard (TPS65950 keypad + `gpio_keys`) | `phase1/n9/hwinit.sh:88-100` |
| **Áudio** | TPS65950 + TWL4030 | Same as N9 |
| **Câmera** | MT9T112 8 MP | Same as N9 |
| **Wi-Fi** | WL1271 | Same as N9 |
| **Bluetooth** | WL1271 + btusb | Same as N9 |
| **Modem** | USB CDC/ACM + QRTR | Same as N9 |
| **Sensores** | LIS331, HMC5843, L3G4200D, GP2A | Same as N9 |
| **Bateria / Carga** | TPS65950 PMIC | Same as N9 |
| **Suspensão** | PM suspend to mem | Same as N9 |
| **Build reproduzível** | **Parcial** — usa build N9; sem KAS target dedicado | `build/meridian-n9.yml` não distingue N950 |
| **Logs de build** | Compartilhados com N9 | |
| **Testes físicos** | A confirmar - requer validação física (dispositivo raro) | |
| **Classificação** | **EXPERIMENTAL** | Device tree existe; sem build dedicado; hardware raro |
| **Plano de recuperação** | Mesmo fluxo N9 | |
| **Riscos de perda de dados** | Mesmo N9 | |

---

## 4. PinePhone (PINE64) — Allwinner A64

| Field | Value | Evidence |
|-------|-------|----------|
| **Fabricante** | PINE64 | |
| **Nome comercial** | PinePhone (A64) | |
| **Codename** | pinephone | `phase1/pinephone/hwinit.sh:39-40` |
| **Variante** | Phone (Linux-first) | |
| **SoC** | Allwinner A64 (4× Cortex-A53) | `phase1/pinephone/hwinit.sh:26-27,41-42` |
| **RAM** | 2 / 3 GB LPDDR3 | A confirmar - requer validação física |
| **Armazenamento** | 16 / 32 GB eMMC + microSD | A confirmar - requer validação física |
| **Revisão de placa** | 1.2 / 1.2a / 1.2b | A confirmar - requer validação física |
| **Bootloader** | U-Boot (mainline) + ARM Trusted Firmware (ATF) | A confirmar - requer validação física |
| **Método de desbloqueio conhecido** | Hardware aberto, sem lock | |
| **Versão atual firmware/OS** | Meridian OS (Debian trixie + OSTree, kernel mainline) | |
| **Kernel source** | Mainline Linux (lima GPU, sunxi DRM) | `phase1/pinephone/hwinit.sh:82-86` `modprobe lima` |
| **Device tree / ACPI** | `sun50i-a64-pinephone.dts` (mainline) | A confirmar - requer validação física |
| **Vendor blobs** | RTL8723CS firmware (Wi-Fi/BT), Quectel EG25 modem firmware | `phase1/pinephone/hwinit.sh:162,130` |
| **Display** | 720×1440 IPS LCD (portrait) | `phase1/pinephone/hwinit.sh:95` |
| **Touch** | Goodix (`goodix` driver + firmware) | `phase1/pinephone/hwinit.sh:109-114` |
| **Áudio** | sun8i codec analog (`snd_soc_sun8i_codec_analog`) | `phase1/pinephone/hwinit.sh:211-213` |
| **Câmera** | OV5640 / GC2145 (`ov5640`, `gc2145`, `v4l2_fwnode`) | `phase1/pinephone/hwinit.sh:192-194` |
| **Wi-Fi** | RTL8723CS (SDIO) (`rtl8723cs`) | `phase1/pinephone/hwinit.sh:162` |
| **Bluetooth** | RTL8723CS + `btusb`, `btintel` | `phase1/pinephone/hwinit.sh:165-166` |
| **Modem** | Quectel EG25 (USB) — `option`, `qmi_wwan`, `cdc_mbim` | `phase1/pinephone/hwinit.sh:124-129` |
| **Sensores** | ST LSM6DSX (accel/gyro), AK09911 (mag), LTR553 (proximity/ALS) | `phase1/pinephone/hwinit.sh:231-239` |
| **Bateria / Carga** | AXP803 PMIC (regulators aldo1-4, bldo1-4, cldo1-3, dldo1-2) | `phase1/pinephone/hwinit.sh:68-72` |
| **Kill switches** | Hardware (modem, wifi, bt, camera, mic) via GPIO | `phase1/pinephone/hwinit.sh:248-263` |
| **Suspensão** | Deep sleep (`mem_sleep=deep`) | `phase1/pinephone/hwinit.sh:278` |
| **Build reproduzível** | **Não** — hwinit existe; **sem KAS build em `device-matrix/build/`** | `build/meridian-n900.yml` e `meridian-n9.yml` só OMAP3 |
| **Logs de build** | A confirmar - requer pipeline dedicado | |
| **Testes físicos** | A confirmar - requer validação física | |
| **Classificação** | **EXPERIMENTAL** | hwinit completo; mainline kernel bom; falta KAS image build |
| **Plano de recuperação** | Boot via SD card (U-Boot mainline);Tow-Boot / U-Boot SPI | A confirmar - requer validação física |
| **Riscos de perda de dados** | eMMC overwrite; kill switches podem desativar modem/Wi-Fi permanentemente se mal configurados | |

---

## 5. PinePhone Pro (PINE64) — Rockchip RK3399

| Field | Value | Evidence |
|-------|-------|----------|
| **Fabricante** | PINE64 | |
| **Nome comercial** | PinePhone Pro | |
| **Codename** | pinephonepro | `phase1/pinephone/hwinit.sh:37-38,43-44` |
| **Variante** | Phone (Linux-first) | |
| **SoC** | Rockchip RK3399 (2× A72 + 4× A53) | `phase1/pinephone/hwinit.sh:43-44` |
| **RAM** | 4 GB LPDDR4 | A confirmar - requer validação física |
| **Armazenamento** | 128 GB eMMC + microSD | A confirmar - requer validação física |
| **Revisão de placa** | A confirmar - requer validação física | |
| **Bootloader** | U-Boot (mainline) + ATF | A confirmar - requer validação física |
| **Método de desbloqueio** | Hardware aberto | |
| **Kernel source** | Mainline (panfrost GPU) | `phase1/pinephone/hwinit.sh:83` `modprobe panfrost` |
| **Device tree** | `rk3399-pinephone-pro.dts` (mainline) | A confirmar - requer validação física |
| **Vendor blobs** | RTL8723CS, Quectel EG25 | Same as PinePhone |
| **Display** | 1440×720 (landscape native) | `phase1/pinephone/hwinit.sh:93` |
| **Touch** | Goodix | Same as PinePhone |
| **Áudio** | RK3399 GRU sound (`snd_soc_rk3399_gru_sound`) | `phase1/pinephone/hwinit.sh:213` |
| **Câmera** | OV5640 / GC2145 | Same as PinePhone |
| **Wi-Fi / BT / Modem / Sensores / PMIC** | Same as PinePhone (AXP809) | `phase1/pinephone/hwinit.sh:59-60` |
| **Kill switches / Suspensão** | Same as PinePhone | |
| **Build reproduzível** | **Não** — mesmo status PinePhone | |
| **Classificação** | **EXPERIMENTAL** | Mesmo status PinePhone; SoC diferente |
| **Plano de recuperação** | Same as PinePhone | |
| **Riscos** | Same as PinePhone | |

---

## 6. Purism Librem 5 (i.MX8M)

| Field | Value | Evidence |
|-------|-------|----------|
| **Fabricante** | Purism | |
| **Nome comercial** | Librem 5 | |
| **Codename** | Librem 5 (Evergreen / Fir / Birch / Chestnut) | `phase1/librem5/hwinit.sh:20` |
| **Variante** | Phone (Linux-first, hardware kill switches) | |
| **SoC** | NXP i.MX8M Quad (4× Cortex-A53) | `phase1/librem5/hwinit.sh:26-27` |
| **RAM** | 3 GB LPDDR4 | A confirmar - requer validação física |
| **Armazenamento** | 32 GB eMMC + microSD | A confirmar - requer validação física |
| **Revisão de placa** | Evergreen (v1.2), Fir, Birch, Chestnut | A confirmar - requer validação física |
| **Bootloader** | U-Boot (mainline) + ATF | A confirmar - requer validação física |
| **Método de desbloqueio** | Hardware aberto, sem lock | |
| **Versão atual firmware/OS** | Meridian OS (Debian trixie + OSTree, kernel mainline) | |
| **Kernel source** | Mainline Linux (etnaviv GPU) | `phase1/librem5/hwinit.sh:57` `modprobe etnaviv` |
| **Device tree** | `imx8mq-librem5.dts` (mainline) | A confirmar - requer validação física |
| **Vendor blobs** | RS9116 firmware (Wi-Fi/BT), BM818 modem firmware | `phase1/librem5/hwinit.sh:131-133,93-98` |
| **Display** | 720×1440 IPS LCD | `phase1/librem5/hwinit.sh:63-64` |
| **Touch** | Goodix (`goodix` + firmware) | `phase1/librem5/hwinit.sh:78-83` |
| **Áudio** | WM8960 (`snd_soc_wm8960`, `snd_soc_imx_*`) | `phase1/librem5/hwinit.sh:183-186` |
| **Câmera** | IMX258 / OV5640 (`imx258`, `ov5640`, `mxc_v4l2_capture`) | `phase1/librem5/hwinit.sh:163-166` |
| **Wi-Fi** | RS9116 (SDIO/USB) (`rsi_91x`, `rsi_usb`, `rsi_sdio`) | `phase1/librem5/hwinit.sh:131-133` |
| **Bluetooth** | RS9116 + `btusb`, `btintel` | `phase1/librem5/hwinit.sh:136-137` |
| **Modem** | BM818 (USB, built-in GNSS) — `option`, `qmi_wwan`, `cdc_mbim` | `phase1/librem5/hwinit.sh:93-98` |
| **GPS** | BM818 built-in GNSS | `phase1/librem5/hwinit.sh:152-153` |
| **Sensores** | BMI160 (accel/gyro), AK09911 (mag), VL53L0X (proximity) | `phase1/librem5/hwinit.sh:204-211` |
| **Bateria / Carga** | BD9571MWV PMIC (buck1-6, ldo1-8) | `phase1/librem5/hwinit.sh:43-47` |
| **Kill switches** | Hardware (modem, wifi, bt, camera, mic) + udev rules | `phase1/librem5/hwinit.sh:220-241` |
| **Botões** | Volume, Power (GPIO keys) | `phase1/librem5/hwinit.sh:244-257, 299-312` |
| **Suspensão** | Deep sleep (`mem_sleep=deep`) | `phase1/librem5/hwinit.sh:293, 351` |
| **Build reproduzível** | **Não** — hwinit existe; **sem KAS build em `device-matrix/build/`** | |
| **Logs de build** | A confirmar - requer pipeline dedicado | |
| **Testes físicos** | A confirmar - requer validação física | |
| **Classificação** | **EXPERIMENTAL** | hwinit completo; mainline kernel bom; falta KAS image build |
| **Plano de recuperação** | Boot via SD card (U-Boot mainline); serial console UART | A confirmar - requer validação física |
| **Riscos de perda de dados** | eMMC overwrite; kill switches mal configurados travam hardware | |

---

## 7. Nokia/Microsoft Lumia 730

| Field | Value | Evidence |
|-------|-------|----------|
| **Fabricante** | Nokia / Microsoft | |
| **Nome comercial** | Lumia 730 | |
| **Codename** | Tesla (internamente) | A confirmar - requer validação física |
| **Variante** | Phone (Windows Phone 8.1 / Windows 10 Mobile) | |
| **SoC** | Qualcomm Snapdragon 400 (MSM8226/MSM8626, 4× Cortex-A7) | A confirmar - requer validação física |
| **RAM** | 1 GB | A confirmar - requer validação física |
| **Armazenamento** | 8 GB eMMC | A confirmar - requer validação física |
| **Revisão de placa** | A confirmar - requer validação física | |
| **Bootloader** | Little Kernel (LK/ABL) + Qualcomm Secure Boot (SBL) | A confirmar - requer validação física |
| **Método de desbloqueio conhecido** | **Desconhecido** — requer exploração (Qualcomm EDL mode, secure boot locked) | |
| **Versão atual firmware/OS** | Windows 10 Mobile (EOL) | |
| **Kernel source** | **Nenhum no mainline** (Qualcomm MSM8926/8226) | `work/research/lumia730/kernel/configs/meridian-omap3_defconfig` é **placeholder OMAP3 copiado** |
| **Device tree / ACPI** | **Nenhum** | `work/research/lumia730/kernel/patches/omap3/series` é **placeholder OMAP3 copiado** |
| **Vendor blobs** | **Proprietários Qualcomm** (não redistribuíveis) | |
| **Display** | 720×1280 OLED | A confirmar - requer validação física |
| **Touch** | Synaptics / Atmel | A confirmar - requer validação física |
| **Áudio** | Qualcomm WCD9320 / WCD9330 | A confirmar - requer validação física |
| **Câmera** | 6.7 MP rear (IMX240?), 5 MP front | A confirmar - requer validação física |
| **Wi-Fi** | Qualcomm QCA6174 / WCN3660 | A confirmar - requer validação física |
| **Bluetooth** | Qualcomm (integrado no WCN3660) | A confirmar - requer validação física |
| **Modem** | Qualcomm MDM9x25 / WTR1605L (integrado no SoC) | A confirmar - requer validação física |
| **Sensores** | Accel, gyro, mag, proximity, ALS | A confirmar - requer validação física |
| **Bateria / Carga** | Qualcomm PM8916 PMIC | A confirmar - requer validação física |
| **Suspensão** | Qualcomm RPM + Linux suspend | A confirmar - requer validação física |
| **Build reproduzível** | **Não** — nenhum componente buildável | |
| **Logs de build** | N/A | |
| **Testes físicos** | A confirmar - requer validação física | |
| **Classificação** | **RESEARCH** | |
| **Gate de entrada** | **Provar boot chain, drivers e recuperação antes de qualquer port de ROM** | Requisito explícito da tarefa |
| **Plano de recuperação** | Qualcomm EDL mode (Emergency Download) se bootloader acessível; caso contrário, JTAG | A confirmar - requer validação física |
| **Riscos de perda de dados** | **Brick permanente** se secure boot violado; eMMC criptografado; sem recovery conhecido | |

---

## 8. Android Targets (Genérico)

| Field | Value | Evidence |
|-------|-------|----------|
| **Categoria** | Dispositivos Android genéricos (port de ROMs Android) | |
| **Infra de build Android** | **Inexistente** — Meridian usa KAS + Debian + OSTree, não AOSP/Lineage | `scripts/build_phase0.sh` só suporta OMAP3 via KAS |
| **Device trees** | **Nenhum** — nenhum `device/<vendor>/<codename>` no repo | |
| **Vendor blobs** | **Nenhum** — blobs proprietários não redistribuíveis | |
| **Kernel sources** | Apenas OMAP3 (N900/N9) no repo; zero device trees ARM64/Android | |
| **Classificação** | **BLOCKED** | |
| **Bloqueador** | **No Android build infra, no device trees, no vendor blobs** | Requisito explícito da tarefa |
| **Pré-requisitos para desbloquear** | 1. Adicionar infra AOSP/Lineage (repo, breakfast, lunch)<br>2. Importar device trees + kernel sources por dispositivo<br>3. Resolver licenciamento de vendor blobs<br>4. Integrar com OSTree ou manter dual-boot | |

---

## Summary Table

| Device | SoC | Arch | Classification | KAS Build | hwinit | Kernel Mainline | Vendor Blobs |
|--------|-----|------|----------------|-----------|--------|-----------------|--------------|
| Nokia N900 | OMAP3430 | armhf | **SUPPORTED** | ✅ `meridian-n900.yml` | ✅ | 6.6 LTS + patches | WL1271 (free) |
| Nokia N9 | OMAP3630 | armhf | **SUPPORTED** | ✅ `meridian-n9.yml` | ✅ | 6.6 LTS + patches | WL1271 (free) |
| Nokia N950 | OMAP3630 | armhf | **EXPERIMENTAL** | ⚠️ usa N9 | ✅ (via N9) | 6.6 LTS + patches | WL1271 (free) |
| PinePhone | Allwinner A64 | arm64 | **EXPERIMENTAL** | ❌ | ✅ | Mainline (lima) | RTL8723CS, EG25 |
| PinePhone Pro | RK3399 | arm64 | **EXPERIMENTAL** | ❌ | ✅ | Mainline (panfrost) | RTL8723CS, EG25 |
| Librem 5 | i.MX8M | arm64 | **EXPERIMENTAL** | ❌ | ✅ | Mainline (etnaviv) | RS9116, BM818 |
| Lumia 730 | Snapdragon 400 | arm64 | **RESEARCH** | ❌ | ❌ (placeholder) | ❌ | Proprietário |
| Android targets | Vários | arm64 | **BLOCKED** | ❌ | ❌ | ❌ | Proprietário |

---

## Próximos Passos Prioritários

1. **N900/N9**: Validar boot físico do `meridian-n900-sd.img`; documentar logs de serial console
2. **PinePhone / PinePhone Pro / Librem 5**: Criar `build/meridian-pinephone.yml`, `build/meridian-librem5.yml` com KAS (base Debian trixie arm64 + mainline kernel + U-Boot mainline)
3. **Lumia 730**: Investigar EDL mode, bootloader unlock, mainline kernel support (Qualcomm MSM8926) — **não investir em port antes do gate**
4. **Android targets**: Decidir se Meridian suporta Android apps via Wayland/Anbox ou se foco permanece Linux nativo

---

## Referências de Código (para rastreabilidade)

- Kernel config OMAP3: `kernel/configs/meridian-omap3_defconfig`
- Kernel patches OMAP3: `kernel/patches/omap3/series` (30 patches)
- KAS build N900: `build/meridian-n900.yml`
- KAS build N9: `build/meridian-n9.yml`
- Phase 0 build script: `scripts/build_phase0.sh`
- Phase 1 hwinit N900: `phase1/n900/hwinit.sh`
- Phase 1 hwinit N9: `phase1/n9/hwinit.sh`
- Phase 1 hwinit PinePhone: `phase1/pinephone/hwinit.sh`
- Phase 1 hwinit Librem 5: `phase1/librem5/hwinit.sh`
- Lumia 730 placeholders: `work/research/lumia730/kernel/configs/...`, `work/research/lumia730/kernel/patches/...`

---

*Gerado em 2026-10-30 a partir da worktree `feat/device-matrix` do repositório Meridian OS.*