#!/bin/bash
# =============================================================================
# generate_release_checksums.sh
# Gera SHA-256SUMS para artifacts de release do Meridian OS (N9 / N900)
# =============================================================================
set -euo pipefail

VERSION="${1:-v0.1.0}"
OUTPUT_DIR="${2:-build/output}"

if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "ERRO: Diretório de saída não encontrado: $OUTPUT_DIR"
    exit 1
fi

echo "=== Gerando checksums SHA-256 para release $VERSION ==="
echo ""

# N900
N900_IMG="$OUTPUT_DIR/meridian-n900-${VERSION}-sd.img"
if [[ -f "$N900_IMG" ]]; then
    echo "--- N900 ---"
    sha256sum "$N900_IMG" > "$OUTPUT_DIR/SHA256SUMS-${VERSION}-n900.txt"
    echo "Gerado: $OUTPUT_DIR/SHA256SUMS-${VERSION}-n900.txt"
    cat "$OUTPUT_DIR/SHA256SUMS-${VERSION}-n900.txt"
else
    echo "AVISO: Imagem N900 não encontrada: $N900_IMG"
fi

echo ""

# N9 / N950
N9_IMG="$OUTPUT_DIR/meridian-n9-${VERSION}-sd.img"
if [[ -f "$N9_IMG" ]]; then
    echo "--- N9 / N950 ---"
    sha256sum "$N9_IMG" > "$OUTPUT_DIR/SHA256SUMS-${VERSION}-n9.txt"
    echo "Gerado: $OUTPUT_DIR/SHA256SUMS-${VERSION}-n9.txt"
    cat "$OUTPUT_DIR/SHA256SUMS-${VERSION}-n9.txt"
else
    echo "AVISO: Imagem N9 não encontrada: $N9_IMG"
fi

echo ""
echo "=== Checksums gerados com sucesso ==="
echo ""
echo "Para verificar:"
echo "  sha256sum -c $OUTPUT_DIR/SHA256SUMS-${VERSION}-n900.txt"
echo "  sha256sum -c $OUTPUT_DIR/SHA256SUMS-${VERSION}-n9.txt"
