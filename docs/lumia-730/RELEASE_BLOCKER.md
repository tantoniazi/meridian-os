# Lumia 730 — Blocker de Release (Sem Versão Instalável)

> **Dispositivo:** Nokia Lumia 730 / 735 (RM-914 / RM-915, codename `eagle`)
> **Data:** 02 de novembro de 2026
> **Status:** **BLOCKED** — nenhuma versão instalável do Meridian OS pode ser gerada para este dispositivo no momento
> **Plano de pesquisa:** `docs/lumia-730/GATE_M0_M1_PLAN.md`

---

## 1. Resumo Executivo

O **Lumia 730 não pode receber uma versão instalável do Meridian OS** (nem de qualquer sistema baseado em Android/LineageOS moderno) devido a bloqueios técnicos fundamentais. Este documento consolida os motivos, as evidências coletadas e os pré-requisitos que seriam necessários para reavaliar a viabilidade.

---

## 2. Motivos do Bloqueio

| # | Bloqueador | Detalhe | Evidência |
|---|------------|---------|-----------|
| 1 | **Arquitetura incompatível** | SoC Snapdragon 400 (MSM8226) é ARMv7-A 32-bit. Meridian requer ARMv8-A 64-bit (mínimo para Android 14+/LineageOS 21+). | `docs/lumia-730/TECHNICAL_ASSESSMENT.md` |
| 2 | **RAM insuficiente** | 1 GB LPDDR3. Meridian requer ≥2 GB (4 GB recomendado). | `docs/lumia-730/DEVICE_SPECS.md` |
| 3 | **Armazenamento insuficiente** | 8 GB eMMC 4.5 (~4,5 GB user available). Meridian requer ≥16 GB. | `docs/lumia-730/DEVICE_SPECS.md` |
| 4 | **Bootloader permanentemente locked** | Microsoft nunca liberou desbloqueio oficial para Lumia 730/735. Não há `fastboot oem unlock`. Sem desbloqueio, não é possível flashar kernel ou system alternativos. | `docs/lumia-730/WINDOWS_RECOVERY_GUIDE.md` |
| 5 | **Sem kernel source público** | Não há kernel source para MSM8226, nem device trees, nem vendor blobs redistribuíveis. | `docs/lumia-730/TECHNICAL_ASSESSMENT.md` |
| 6 | **Sem suporte upstream** | Zero device trees LineageOS/AOSP, zero kernel sources no GitHub/Gerrit, zero mantenedores ativos, sem TWRP/custom recovery. | `docs/lumia-730/TECHNICAL_ASSESSMENT.md` |
| 7 | **Secure Boot / Verified Boot** | UEFI Secure Boot ativo no Windows 10 Mobile. Partições críticas (aboot, tz, rpm, sbl1) são assinadas e verificadas. | `docs/lumia-730/TECHNICAL_ASSESSMENT.md` |

---

## 3. O que é Possível Instalar no Lumia 730

| Sistema | Status | Como |
|---------|--------|------|
| Windows 10 Mobile (15254.603) | ✅ Oficial | Windows Device Recovery Tool (WDRT) |
| Windows Phone 8.1 | ✅ Oficial | WDRT (firmware mais antigo) |
| Android / LineageOS / Custom ROMs | ❌ Impossível | Bootloader locked, sem kernel source |
| Meridian OS | ❌ Impossível | Todos os bloqueadores acima |

---

## 4. Pré-requisitos para Reavaliar (Gate M0/M1)

Para que uma versão instalável seja considerada, todos os seguintes gates precisam ser superados:

### Gate M0 — Boot Chain e Recuperação
| Critério | Status | O que seria necessário |
|----------|--------|----------------------|
| Dispositivo físico adquirido | ☐ | Comprar Lumia 730 (RM-914 preferido) |
| Firmware oficial 15254.603 baixado | ☐ | Via WDRT ou NaviFirm (product code 059Wxxx) |
| WDRT restaura aparelho ao original | ☐ | Testar em aparelho funcionando |
| Backup completo do eMMC | ☐ | Todas as partições (sbl1, rpm, tz, aboot, boot, dtbo, vbmeta, system, vendor, userdata, modem, persist) |
| Restauração do backup testada | ☐ | Aparelho volta a funcionar após restore |

### Gate M1 — Kernel Mainline e Drivers Básicos
| Critério | Status | O que seria necessário |
|----------|--------|----------------------|
| Test points EDL identificados | ☐ | Desmontar, localizar TP_E1/TP_E2, documentar com fotos |
| EDL mode verificado (`05c6:9008`) | ☐ | `lsusb` mostra Qualcomm QDL mode |
| Kernel mainline compila para MSM8226 | ☐ | `arch/arm64/boot/dts/qcom/msm8226.dtsi` existe; verificar se há board DT específico |
| Kernel boota até serial console | ☐ | UART 115200 8N1, 1.8V com level shifter |
| Display funciona | ☐ | Framebuffer visível |
| Toque responsivo | ☐ | `evtest` output |
| eMMC leitura/escrita | ☐ | `mount` + teste de gravação |
| Modem firmware carrega | ☐ | `mmcli -L` ou `qmicli` |
| Recuperação após flash de kernel | ☐ | Backup restaurado, aparelho volta ao Windows |

---

## 5. Critérios de Parada Automática (STOP)

Qualquer um destes itens resulta em **interrupção imediata** do projeto Lumia 730:

1. Não é possível entrar em EDL mode após 3 tentativas com dispositivos diferentes
2. Não é possível restaurar o backup do eMMC (aparelho não volta ao Windows)
3. Kernel mainline não bootara após 4 semanas de iteração
4. Display ou toque não funcionam após kernel bootando

---

## 6. Recomendação do Projeto

Conforme `docs/lumia-730/TECHNICAL_ASSESSMENT.md`:

| Opção | Custo aproximado | Resultado |
|-------|-----------------|-----------|
| Manter Lumia 730 como está | Grátis | GPS offline / câmera / MP3 / backup de chamadas |
| Vender Lumia 730 | +R$ 150-250 | Fundo para dispositivo suportado |
| Comprar Pixel 3a (usado) | ~R$ 300 | LineageOS 21, 4 GB RAM, 64 GB, bootloader desbloqueável |
| Comprar Pixel 4a (usado) | ~R$ 400 | LineageOS 21, 6 GB RAM |
| Comprar Pixel 6a (usado) | ~R$ 600 | LineageOS 21, Tensor, 6 GB |

**Recomendação:** Vender o Lumia 730 e usar o valor para adquirir um dispositivo com bootloader desbloqueável e suporte LineageOS (ex: Pixel 3a/4a/6a). O Lumia 730 permanece como dispositivo de referência documental apenas para pesquisa de boot chain.

---

## 7. Arquivos Relacionados no Repositório

| Arquivo | Conteúdo |
|---------|----------|
| `docs/lumia-730/DEVICE_SPECS.md` | Especificações completas do hardware |
| `docs/lumia-730/TECHNICAL_ASSESSMENT.md` | Avaliação técnica: por que não é viável |
| `docs/lumia-730/WINDOWS_RECOVERY_GUIDE.md` | Recuperação Windows 10 Mobile via WDRT |
| `docs/lumia-730/GATE_M0_M1_PLAN.md` | Plano de pesquisa para tentar passar os gates |
| `docs/lumia730-research.md` | Plano de boot/kernel com gate criteria |
| `DEVICE_MATRIX.md` | Matriz de dispositivos (Lumia 730 classificado RESEARCH/BLOCKED) |

---

> **Aviso:** Operações de EDL mode e flash de partições críticas (aboot, tz, rpm, sbl1) podem causar **brick permanente**. Nunca execute sem backup completo verificado. O projeto Meridian não se responsabiliza por danos ao hardware.