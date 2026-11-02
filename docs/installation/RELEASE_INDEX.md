# Índice de Releases — Meridian OS

> **Data:** 02 de novembro de 2026

---

## 1. Releases por Dispositivo

| Dispositivo | Versão | Status | Artifact | Checksums | Documentação |
|-------------|--------|--------|----------|-----------|--------------|
| Nokia N900 (RX-51) | v0.1.0 | **Disponível (nightly)** | `meridian-n900-v0.1.0-sd.img` | `SHA256SUMS-v0.1.0-n900.txt` | `N9_N900_RELEASE_v0.1.0.md` |
| Nokia N9 (RM-696) | v0.1.0 | **Disponível (nightly)** | `meridian-n9-v0.1.0-sd.img` | `SHA256SUMS-v0.1.0-n9.txt` | `N9_N900_RELEASE_v0.1.0.md` |
| Nokia N950 (RM-680) | v0.1.0 | **Disponível (nightly, via build N9)** | `meridian-n9-v0.1.0-sd.img` | `SHA256SUMS-v0.1.0-n9.txt` | `N9_N900_RELEASE_v0.1.0.md` |
| Nokia Lumia 730 (RM-914/915) | — | **BLOCKED** | Nenhum | Nenhum | `RELEASE_BLOCKER.md` |

---

## 2. Canais de Release

| Canal | Frequência | Versionamento | Uso |
|-------|------------|---------------|-----|
| **Nightly** | Diária (automática) | `YYYY.MM.DD-nightly` | Desenvolvedores, testes básicos |
| **Weekly** | Semanal | `YYYY.WW-weekly` | Testers, changelog gerado |
| **Monthly** | Mensal | `vX.Y.0-monthly` | Stable candidate, suíte completa de testes |
| **Stable** | Trimestral | `vX.Y.Z` | Release tagado, assinado produção, suporte 6 meses |

---

## 3. Como Gerar uma Nova Versão

```bash
# 1. Build completo (kernel + U-Boot + rootfs + imagem SD)
bash scripts/build_phase0.sh all

# 2. Gerar checksums SHA-256
bash scripts/generate_release_checksums.sh v0.1.0 build/output

# 3. Verificar checksums
sha256sum -c build/output/SHA256SUMS-v0.1.0-n900.txt
sha256sum -c build/output/SHA256SUMS-v0.1.0-n9.txt

# 4. Flash no aparelho (exemplo N900)
sudo dd if=build/output/meridian-n900-v0.1.0-sd.img of=/dev/sdX bs=4M status=progress conv=fsync
```

---

## 4. Metadados OTA

O arquivo `ota/ota_metadata_v0.1.0.json` contém os metadados para o cliente `meridian-update`, incluindo URLs de download, checksums, assinaturas e informações de hardware por dispositivo.

**Nota:** As URLs apontam para GitHub Releases. Os artifacts precisam ser publicados lá antes que o cliente OTA possa consumir os metadados.

---

## 5. Documentação por Dispositivo

| Arquivo | Dispositivo | Conteúdo |
|---------|-------------|----------|
| `docs/installation/N9_N900_RELEASE_v0.1.0.md` | N9 / N900 / N950 | Release notes completa, pacotes, hardware, instalação, checksums |
| `docs/installation/RELEASE_INDEX.md` | Todos | Este índice |
| `docs/lumia-730/RELEASE_BLOCKER.md` | Lumia 730 | Por que não há versão instalável, gates M0/M1, recomendação |
| `docs/lumia-730/GATE_M0_M1_PLAN.md` | Lumia 730 | Plano de pesquisa para tentar desbloquear o dispositivo |
| `ota/ota_metadata_v0.1.0.json` | N9 / N900 / N950 | Metadados OTA para cliente `meridian-update` |

---

## 6. Scripts de Release

| Script | Função |
|--------|--------|
| `scripts/generate_release_checksums.sh` | Gera SHA-256SUMS para artifacts N9/N900 |
| `scripts/build_phase0.sh` | Pipeline completo de build (kernel, U-Boot, rootfs, imagem SD) |
| `tools/installer/release/release.go` | Cliente Go que baixa e verifica releases do GitHub (SHA-256) |

---

## 7. Próximos Passos

1. **Validar boot físico** em N9 e N900 (serial console, display, toque, áudio, Wi-Fi, Bluetooth, modem, câmera, sensores)
2. **Configurar assinatura de release** (chave dev offline, depois chave de produção em HSM/YubiKey)
3. **Publicar artifacts no GitHub Releases** com tag `meridian-n900-v0.1.0` e `meridian-n9-v0.1.0`
4. **Atualizar metadados OTA** com URLs e tamanhos reais após publicação
5. **Lumia 730:** Não avançar até passar Gate M0 (backup e restauração de eMMC) — veja `RELEASE_BLOCKER.md`

---

> **Aviso:** Flashar firmware em aparelhos físicos pode causar perda de dados ou brick permanente. Faça backup completo antes de prosseguir.