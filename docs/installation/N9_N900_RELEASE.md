# Meridian OS — Release N9 / N900 (OMAP3)

> **Versão:** 2026.10 (primeira release instalável)
> **Data:** 31 de outubro de 2026
> **Arquitetura:** armhf (32-bit)
> **Base:** Debian trixie + OSTree
> **Kernel:** Linux 6.6 LTS + patches OMAP3 (30 patches)
> **Bootloader:** U-Boot + MLO (X-Loader)
> **Dispositivos:** Nokia N900 (RX-51), Nokia N9 (RM-696 "Lankku"), Nokia N950 (RM-680, compartilha build N9)
> **Classificação:** SUPPORTED (kernel config + KAS build + hwinit completos)

---

## 1. O que está nesta release

| Componente | N900 | N9 / N950 | Fonte |
|------------|------|-----------|-------|
| Kernel | 6.6 LTS + OMAP3 patches | 6.6 LTS + OMAP3 patches | `kernel/configs/meridian-omap3_defconfig` + `kernel/patches/omap3/series` |
| U-Boot | `u-boot-meridian-n900` + MLO | `u-boot-meridian-n9` | `build/output/u-boot/n900/`, `build/output/u-boot/n9/` |
| DTB | `omap3-n900.dtb` | `omap3-n9.dtb` / `omap3-n950.dtb` | `kernel/patches/omap3/series:37-39` |
| Rootfs | Debian trixie + OSTree | Debian trixie + OSTree | KAS (`build/meridian-n900.yml`, `build/meridian-n9.yml`) |
| OSTree branch | `meridian/phone-n900` | `meridian/phone-n9` | Commit datado `$(date +%Y%m%d)` |
| Imagem de boot | `meridian-n900-sd.img` (4G) | `meridian-n9-sd.img` (4G) | `scripts/build_phase0.sh` (fase `sd`) |

### Pacotes incluídos (ambos os dispositivos)

- **Base:** `meridian-base`, `meridian-kernel-omap3`, `meridian-shell`, `meridian-home`, `meridian-settings`
- **Apps:** `meridian-dialer`, `meridian-messages`, `meridian-contacts`, `meridian-camera`, `meridian-browser`, `meridian-file-manager`, `meridian-terminal`, `meridian-store`
- **Sistema:** `ostree`, `systemd`, `pipewire`, `wireplumber`, `ModemManager`, `NetworkManager`, `bluez`, `gpsd`, `sensorfw`, `libcamera`, `mesa`, `weston`, `maliit-keyboard`, `qt6-*`, `gtk4`, `libadwaita-1`, `xwayland`
- **Hardware:** `linux-image-meridian-omap3`, `linux-firmware`, `firmware-ti-connectivity`, `u-boot-tools`, `mtd-utils`, `mtd-utils-ubifs`, `flash-kernel`
- **Utilitários:** `vim-tiny`, `less`, `bash-completion`, `curl`, `wget`, `ca-certificates`, `openssh-client`, `openssh-server`, `sudo`, `locales`, `tzdata`, `plymouth`, `plymouth-theme-meridian`

---

## 2. Suporte de hardware por dispositivo

### Nokia N900 (RX-51)

| Subsistema | Status | Driver / Fonte |
|------------|--------|----------------|
| SoC | OMAP3430 (Cortex-A8 @ 600 MHz) | `CONFIG_SOC_OMAP3430=y` |
| Display | 800×480 resistive, TV-out composite | `phase1/n900/hwinit.sh:55-58,115-126` |
| Toque | TPS65950 touchscreen | `tps65950_ts`, `tsc2007` |
| Áudio | TPS65950 + TWL4030 | `snd_soc_tps65950`, `snd_soc_twl4030` |
| Câmera | MT9T111 5 MP traseira | `mt9t111`, `omap3_camera` |
| Wi-Fi | WL1271 (SDIO) | `kernel/patches/omap3/series:30` |
| Bluetooth | WL1271 (compartilhado com Wi-Fi) | `bluez` |
| Modem | HSI interface | `hsi_char`, `ti_hsi`, ofono + ModemManager |
| Sensores | LIS331, HMC5843, L3G4200D | `phase1/n900/hwinit.sh:226-233` |
| Bateria / Carga | TPS65950 PMIC | `phase1/n900/hwinit.sh:35-44` |
| Suspensão | Suspend to mem | `echo mem > /sys/power/state` |

### Nokia N9 (RM-696) / N950 (RM-680)

| Subsistema | Status | Driver / Fonte |
|------------|--------|----------------|
| SoC | OMAP3630 (Cortex-A8 @ 1 GHz) | `phase1/n9/hwinit.sh:26` |
| Display | 854×480 AMOLED | `phase1/n9/hwinit.sh:56-58` |
| Toque | Synaptics RMI4 | `synaptics_i2c`, `synaptics_rmi4` |
| Áudio | TPS65950 + TWL4030 | `snd_soc_tps65950`, `snd_soc_twl4030` |
| Câmera | MT9T112 8 MP traseira | `mt9t112`, `omap3_camera` |
| Wi-Fi | WL1271 | `phase1/n9/hwinit.sh:237-240` |
| Bluetooth | WL1271 + btusb | `phase1/n9/hwinit.sh:243-245` |
| Modem | USB CDC/ACM + QRTR | `option`, `qmi_wwan`, `cdc_acm`, `cdc_wdm` |
| Sensores | LIS331, HMC5843, L3G4200D, GP2A | `phase1/n9/hwinit.sh:213-224` |
| Teclado (N950) | Hardware keyboard | `gpio_keys` (TPS65950 keypad) |
| Bateria / Carga | TPS65950 PMIC | `phase1/n9/hwinit.sh:40-44` |
| Suspensão | Suspend to mem | `phase1/n9/hwinit.sh:266` |

---

## 3. Limitações conhecidas

1. **Validação física pendente:** Nenhum dos dispositivos teve boot comprovado em hardware físico. A classificação SUPPORTED refere-se à build pipeline completa (KAS + hwinit), não ao boot real no aparelho.
2. **N950 sem build dedicado:** Compartilha a build do N9; não há KAS target próprio nem DT overlay diferenciado além do `omap3-n950.dtb`.
3. **Sem serial console documentado:** Não há procedimento documentado para captura de logs de serial console durante o boot inicial.
4. **Partição `/home` separada no OSTree deploy:** Backup recomendado antes de qualquer flash.

---

## 4. Como gerar a imagem (build)

Pré-requisitos (ver `scripts/build_phase0.sh`):

```bash
kas debootstrap mmdebstrack qemu-user-static binfmt-support \
  arm-linux-gnueabihf-gcc u-boot-tools dtc mkimage
```

Build completo (kernel + U-Boot + rootfs + imagem SD):

```bash
cd /home/tiagoadg/Codes/tantoniazi/meridian-os
bash scripts/build_phase0.sh all
```

Fases individuais:

```bash
bash scripts/build_phase0.sh kernel   # Kernel OMAP3
bash scripts/build_phase0.sh uboot    # U-Boot N900 + N9
bash scripts/build_phase0.sh rootfs   # Debian trixie via OSTree
bash scripts/build_phase0.sh images   # KAS builds (n900 + n9)
bash scripts/build_phase0.sh sd       # Imagem SD bootável (n900 por padrão)
```

Saídas:

```
build/output/kernel/omap3/          # zImage, DTBs
build/output/u-boot/n900/           # MLO, u-boot.img (N900)
build/output/u-boot/n9/             # MLO, u-boot.img (N9)
build/output/meridian-n900-sd.img   # Imagem SD 4G (N900)
build/tmp/deploy/ostree/repo/       # Repositório OSTree
```

---

## 5. Como instalar (flash no aparelho)

### Pré-requisitos

- Cartão microSD ≥ 8 GB (classe 10 recomendado)
- Leitor de cartão SD no PC
- Linux com `dd`, `lsblk`, `mkfs.vfat`, `mkfs.ext4`
- Acesso root/sudo

> **Atenção:** O comando `dd` abaixo sobrescreve completamente o dispositivo de destino. Verifique duas vezes o caminho do cartão (`/dev/sdX`) antes de executar. Um erro aqui pode destruir dados do seu PC.

### Passo a passo

**1. Identifique o cartão SD:**

```bash
lsblk
# Procure pelo dispositivo correspondente ao seu cartão, ex: /dev/sdb
# NUNCA use /dev/sda (geralmente o disco principal do sistema)
```

**2. Desmonte todas as partições do cartão:**

```bash
sudo umount /dev/sdX1 2>/dev/null || true
sudo umount /dev/sdX2 2>/dev/null || true
```

**3. Faça o flash da imagem:**

```bash
# Para N900:
sudo dd if=build/output/meridian-n900-sd.img of=/dev/sdX bs=4M status=progress conv=fsync

# Para N9 (se houver imagem dedicada gerada):
# sudo dd if=build/output/meridian-n9-sd.img of=/dev/sdX bs=4M status=progress conv=fsync
```

**4. Ejecte o cartão com segurança:**

```bash
sudo eject /dev/sdX
```

**5. Insira o cartão no aparelho e ligue:**

- **N900:** O U-Boot (MLO) carrega do cartão SD e inicia o kernel Meridian.
- **N9:** Mesma abordagem via U-Boot N9.

**6. Primeiro boot:**

O primeiro boot pode demorar (OSTree deploy, geração de locales, inicialização de serviços). A senha padrão do root é `meridian` (conforme `post_processing_commands` nos builds).

**7. Verificação inicial:**

```bash
# No terminal do aparelho (ou via SSH):
uname -a                    # Deve mostrar Linux 6.6 LTS
cat /etc/os-release         # Debian trixie
ostree refs                 # Deve listar meridian/phone-n900 ou meridian/phone-n9
```

---

## 6. Recuperação e rollback

- **Flash novamente:** Repita o passo 5 com uma imagem SD nova ou a mesma para restaurar o estado inicial.
- **Backup de `/home`:** A partição `/home` é separada no deploy OSTree. Faça backup antes de qualquer operação destrutiva.
- **Não há modo de recuperação embutido:** Se o boot falhar, reflashe o cartão SD.

---

## 7. Checklist de validação física (pendente)

Este checklist ainda não foi executado em hardware real:

- [ ] Boot via serial console (capturar logs de U-Boot → kernel → initramfs)
- [ ] Display funciona (framebuffer visível)
- [ ] Toque responsivo (`evtest` ou equivalente)
- [ ] Áudio (teste de playback e captura)
- [ ] Wi-Fi (scan + conexão)
- [ ] Bluetooth (hcitool / bluetoothctl)
- [ ] Modem (detecção via `mmcli` ou `qmicli`)
- [ ] Câmera (captura de imagem via `meridian-camera`)
- [ ] Sensores (acelerômetro, magnômetro, giroscópio)
- [ ] Suspensão e retomada (`echo mem > /sys/power/state`)

---

## 8. Referências internas

- `build/meridian-n900.yml` — KAS build config N900
- `build/meridian-n9.yml` — KAS build config N9 / N950
- `scripts/build_phase0.sh` — Script de build Phase 0
- `kernel/patches/omap3/series` — 30 patches OMAP3
- `phase1/n900/hwinit.sh` — Bring-up N900
- `phase1/n9/hwinit.sh` — Bring-up N9 / N950
- `DEVICE_MATRIX.md` — Matriz completa de dispositivos

---

> **Aviso:** Flashar firmware em aparelhos físicos pode causar perda de dados ou brick permanente. Faça backup completo antes de prosseguir. O projeto Meridian não se responsabiliza por danos ao hardware.