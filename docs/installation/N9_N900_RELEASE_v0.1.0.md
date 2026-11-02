# Meridian OS — Release v0.1.0 para Nokia N9 / N900 (OMAP3)

> **Versão:** v0.1.0 (primeira release instalável)
> **Data:** 02 de novembro de 2026
> **Arquitetura:** armhf (32-bit)
> **Base:** Debian trixie + OSTree
> **Kernel:** Linux 6.6 LTS + patches OMAP3 (30 patches)
> **Bootloader:** U-Boot + MLO (X-Loader)
> **Dispositivos:** Nokia N900 (RX-51), Nokia N9 (RM-696 "Lankku"), Nokia N950 (RM-680, compartilha build N9)
> **Classificação:** SUPPORTED (kernel config + KAS build + hwinit completos)
> **Canal:** nightly → weekly → monthly

---

## 1. Sumário da Release

Esta é a **primeira release instalável** do Meridian OS para dispositivos Nokia baseados em OMAP3 (N900, N9, N950). A imagem é entregue como um cartão SD bootável contendo U-Boot, kernel Linux 6.6 LTS, device trees e um rootfs Debian trixie implantado via OSTree.

| Item | Valor |
|------|-------|
| Tag da release | `meridian-n900-v0.1.0`, `meridian-n9-v0.1.0` |
| Branch OSTree N900 | `meridian/phone-n900` |
| Branch OSTree N9/N950 | `meridian/phone-n9` |
| Tamanho da imagem SD | 4 GB |
| Formato de flash | `dd` direto no cartão SD |
| Verificação | SHA-256 (ver seção 5) |
| Assinatura | Pendente (chave dev assinada offline) |

---

## 2. Artifacts da Release

| Artifact | N900 | N9 / N950 | Descrição |
|----------|------|-----------|-----------|
| Imagem SD | `meridian-n900-v0.1.0-sd.img` | `meridian-n9-v0.1.0-sd.img` | Imagem bootável completa (U-Boot + kernel + OSTree) |
| Kernel | `zImage-v0.1.0-omap3-n900` | `zImage-v0.1.0-omap3-n9` | Kernel Linux 6.6 LTS + patches OMAP3 |
| DTB | `omap3-n900.dtb` | `omap3-n9.dtb` / `omap3-n950.dtb` | Device Tree Blobs |
| U-Boot | `MLO` + `u-boot.img` | `MLO` + `u-boot.img` | Bootloader estágio inicial + principal |
| OSTree repo | `ostree-repo-n900-v0.1.0.tar` | `ostree-repo-n9-v0.1.0.tar` | Repositório OSTree para atualizações futuras |
| Checksums | `SHA256SUMS-v0.1.0-n900.txt` | `SHA256SUMS-v0.1.0-n9.txt` | Hashes SHA-256 de todos artifacts |

---

## 3. Pacotes Incluídos (ambos os dispositivos)

### Base
- `meridian-base`, `meridian-kernel-omap3`, `meridian-shell`, `meridian-home`, `meridian-settings`

### Aplicações
- `meridian-dialer`, `meridian-messages`, `meridian-contacts`, `meridian-camera`
- `meridian-browser`, `meridian-file-manager`, `meridian-terminal`, `meridian-store`

### Sistema
- `ostree`, `systemd`, `pipewire`, `wireplumber`, `ModemManager`, `NetworkManager`
- `bluez`, `gpsd`, `sensorfw`, `libcamera`, `mesa`, `weston`, `maliit-keyboard`
- `qt6-*`, `gtk4`, `libadwaita-1`, `xwayland`, `plymouth`, `plymouth-theme-meridian`

### Hardware
- `linux-image-meridian-omap3`, `linux-firmware`, `firmware-ti-connectivity`
- `u-boot-tools`, `mtd-utils`, `mtd-utils-ubifs`, `flash-kernel`

### Utilitários
- `vim-tiny`, `less`, `bash-completion`, `curl`, `wget`, `ca-certificates`
- `openssh-client`, `openssh-server`, `sudo`, `locales`, `tzdata`

---

## 4. Suporte de Hardware por Dispositivo

### Nokia N900 (RX-51)

| Subsistema | Driver / Fonte | Status |
|------------|----------------|--------|
| SoC | OMAP3430 (Cortex-A8 @ 600 MHz) | `CONFIG_SOC_OMAP3430=y` |
| Display | 800×480 resistive, TV-out composite | `phase1/n900/hwinit.sh` |
| Toque | TPS65950 touchscreen | `tps65950_ts`, `tsc2007` |
| Áudio | TPS65950 + TWL4030 | `snd_soc_tps65950`, `snd_soc_twl4030` |
| Câmera | MT9T111 5 MP traseira | `mt9t111`, `omap3_camera` |
| Wi-Fi | WL1271 (SDIO) | `kernel/patches/omap3/series:30` |
| Bluetooth | WL1271 | `bluez` |
| Modem | HSI interface | `hsi_char`, `ti_hsi`, ofono + ModemManager |
| Sensores | LIS331, HMC5843, L3G4200D | `phase1/n900/hwinit.sh:226-233` |
| Bateria / Carga | TPS65950 PMIC | `phase1/n900/hwinit.sh:35-44` |
| Suspensão | Suspend to mem | `echo mem > /sys/power/state` |

### Nokia N9 (RM-696) / N950 (RM-680)

| Subsistema | Driver / Fonte | Status |
|------------|----------------|--------|
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

## 5. Checksums SHA-256 (v0.1.0)

> **Nota:** Os hashes abaixo são placeholders. Eles devem ser gerados após o build real com `sha256sum` nos artifacts finais.

### N900
```
SHA256 (meridian-n900-v0.1.0-sd.img)  =  <pendente>
SHA256 (zImage-v0.1.0-omap3-n900)    =  <pendente>
SHA256 (omap3-n900.dtb)              =  <pendente>
SHA256 (MLO-n900)                    =  <pendente>
SHA256 (u-boot.img-n900)             =  <pendente>
SHA256 (ostree-repo-n900-v0.1.0.tar) =  <pendente>
```

### N9 / N950
```
SHA256 (meridian-n9-v0.1.0-sd.img)   =  <pendente>
SHA256 (zImage-v0.1.0-omap3-n9)     =  <pendente>
SHA256 (omap3-n9.dtb)               =  <pendente>
SHA256 (omap3-n950.dtb)             =  <pendente>
SHA256 (MLO-n9)                     =  <pendente>
SHA256 (u-boot.img-n9)              =  <pendente>
SHA256 (ostree-repo-n9-v0.1.0.tar)  =  <pendente>
```

### Verificação
```bash
# Verificar checksums após download
sha256sum -c SHA256SUMS-v0.1.0-n900.txt

# Ou verificar individualmente
sha256sum meridian-n900-v0.1.0-sd.img
```

---

## 6. Como Gerar a Release (Build)

### Pré-requisitos
```bash
sudo apt install kas debootstrap mmdebstrap qemu-user-static binfmt-support \
  arm-linux-gnueabihf-gcc u-boot-tools dtc mkimage
```

### Build completo
```bash
cd /home/tiagoadg/Codes/tantoniazi/meridian-os
bash scripts/build_phase0.sh all
```

### Gerar imagem SD (apenas)
```bash
bash scripts/build_phase0.sh sd
```

### Gerar checksums
```bash
cd build/output
sha256sum meridian-n900-v0.1.0-sd.img > SHA256SUMS-v0.1.0-n900.txt
sha256sum meridian-n9-v0.1.0-sd.img > SHA256SUMS-v0.1.0-n9.txt
```

### Saídas do build
```
build/output/kernel/omap3/          # zImage, DTBs
build/output/u-boot/n900/           # MLO, u-boot.img (N900)
build/output/u-boot/n9/             # MLO, u-boot.img (N9)
build/output/meridian-n900-v0.1.0-sd.img
build/output/meridian-n9-v0.1.0-sd.img
build/tmp/deploy/ostree/repo/       # Repositório OSTree
```

---

## 7. Como Instalar (Flash no Aparelho)

### Pré-requisitos
- Cartão microSD ≥ 8 GB (classe 10)
- Leitor de cartão SD no PC
- Linux com `dd`, `lsblk`, acesso root/sudo

> **Atenção:** O comando `dd` sobrescreve completamente o dispositivo de destino. Verifique duas vezes o caminho (`/dev/sdX`) antes de executar.

### Passo a passo

**1. Identificar o cartão SD:**
```bash
lsblk
# Exemplo: /dev/sdb (NUNCA /dev/sda — disco principal do sistema)
```

**2. Desmontar partições:**
```bash
sudo umount /dev/sdX1 2>/dev/null || true
sudo umount /dev/sdX2 2>/dev/null || true
```

**3. Fazer flash da imagem:**

Para N900:
```bash
sudo dd if=meridian-n900-v0.1.0-sd.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Para N9/N950:
```bash
sudo dd if=meridian-n9-v0.1.0-sd.img of=/dev/sdX bs=4M status=progress conv=fsync
```

**4. Ejectar com segurança:**
```bash
sudo eject /dev/sdX
```

**5. Inserir cartão no aparelho e ligar.**

### Primeiro boot
O primeiro boot pode demorar (OSTree deploy, geração de locales, inicialização de serviços).
Senha padrão do root: `meridian` (definida em `post_processing_commands` nos builds KAS).

**Verificação inicial no terminal do aparelho:**
```bash
uname -a                    # Linux 6.6 LTS
cat /etc/os-release         # Debian trixie
ostree refs                 # meridian/phone-n900 ou meridian/phone-n9
```

---

## 8. Recuperação e Rollback

- **Flash novamente:** Repita a seção 7 com uma imagem SD nova ou a mesma para restaurar o estado inicial.
- **Backup de `/home`:** A partição `/home` é separada no deploy OSTree. Faça backup antes de qualquer operação destrutiva.
- **Não há modo de recuperação embutido:** Se o boot falhar, reflashe o cartão SD.

---

## 9. Checklist de Validação Física (Pendente)

Este checklist ainda não foi executado em hardware real:

- [ ] Boot via serial console (U-Boot → kernel → initramfs)
- [ ] Display funciona (framebuffer visível)
- [ ] Toque responsivo (`evtest` ou equivalente)
- [ ] Áudio (playback e captura)
- [ ] Wi-Fi (scan + conexão)
- [ ] Bluetooth (`bluetoothctl`)
- [ ] Modem (detecção via `mmcli` ou `qmicli`)
- [ ] Câmera (captura de imagem)
- [ ] Sensores (acelerômetro, magnômetro, giroscópio)
- [ ] Suspensão e retomada (`echo mem > /sys/power/state`)

---

## 10. Limitações Conhecidas

1. **Validação física pendente:** Nenhum dispositivo teve boot comprovado em hardware real. A classificação SUPPORTED refere-se à build pipeline completa (KAS + hwinit), não ao boot real.
2. **N950 sem build dedicado:** Compartilha a build do N9; não há KAS target próprio.
3. **Sem serial console documentado:** Não há procedimento documentado para captura de logs de serial console durante o boot inicial.
4. **Assinatura pendente:** Chaves de assinatura de release ainda não configuradas (chave dev assinada offline apenas).

---

## 11. Referências Internas

- `build/meridian-n900.yml` — KAS build config N900
- `build/meridian-n9.yml` — KAS build config N9 / N950
- `scripts/build_phase0.sh` — Script de build Phase 0
- `kernel/patches/omap3/series` — 30 patches OMAP3
- `phase1/n900/hwinit.sh` — Bring-up N900
- `phase1/n9/hwinit.sh` — Bring-up N9 / N950
- `DEVICE_MATRIX.md` — Matriz completa de dispositivos
- `docs/lumia-730/GATE_M0_M1_PLAN.md` — Plano de pesquisa Lumia 730 (bloqueado)

---

> **Aviso:** Flashar firmware em aparelhos físicos pode causar perda de dados ou brick permanente. Faça backup completo antes de prosseguir. O projeto Meridian não se responsabiliza por danos ao hardware.