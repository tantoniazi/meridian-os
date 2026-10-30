#!/bin/bash
# Meridian OS - Build U-Boot for N900/N9

set -euo pipefail

UBOOT_DIR="/home/tiagoadg/Codes/tantoniazi/meridian-os/bootloader/u-boot"
BUILD_DIR="/tmp/meridian-u-boot"
OUTPUT_DIR="/home/tiagoadg/Codes/tantoniazi/meridian-os/build/output/u-boot"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check if we're in the right place
if [[ ! -d "$UBOOT_DIR" ]]; then
    error "U-Boot source directory not found at $UBOOT_DIR"
fi

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

log "Building U-Boot for N900..."
cd "$UBOOT_DIR"
make O="$BUILD_DIR/n900" meridian_n900_defconfig
make -j$(nproc) O="$BUILD_DIR/n900"

# Copy artifacts
mkdir -p "$OUTPUT_DIR/n900"
cp "$BUILD_DIR/n900/u-boot.img" "$OUTPUT_DIR/n900/"
cp "$BUILD_DIR/n900/u-boot.bin" "$OUTPUT_DIR/n900/"
cp "$BUILD_DIR/n900/u-boot.scr" "$OUTPUT_DIR/n900/" 2>/dev/null || true
cp "$BUILD_DIR/n900/MLO" "$OUTPUT_DIR/n900/" 2>/dev/null || true

log "N900 U-Boot built successfully at $OUTPUT_DIR/n900/"

log "Building U-Boot for N9/N950..."
cd "$UBOOT_DIR"
make O="$BUILD_DIR/n9" meridian_n9_defconfig
make -j$(nproc) O="$BUILD_DIR/n9"

# Copy artifacts
mkdir -p "$OUTPUT_DIR/n9"
cp "$BUILD_DIR/n9/u-boot.img" "$OUTPUT_DIR/n9/"
cp "$BUILD_DIR/n9/u-boot.bin" "$OUTPUT_DIR/n9/"
cp "$BUILD_DIR/n9/u-boot.scr" "$OUTPUT_DIR/n9/" 2>/dev/null || true
cp "$BUILD_DIR/n9/MLO" "$OUTPUT_DIR/n9/" 2>/dev/null || true

log "N9/N950 U-Boot built successfully at $OUTPUT_DIR/n9/"

# Create MLO (x-loader) for N900 if needed
if [[ -f "$BUILD_DIR/n900/MLO" ]]; then
    log "MLO (x-loader) found for N900"
fi

log "U-Boot build complete!"
log "Output: $OUTPUT_DIR"
log ""
log "Next steps:"
log "  1. Flash MLO and u-boot.img to device:"
log "     sudo dd if=$OUTPUT_DIR/n900/MLO of=/dev/sdX bs=128k seek=1"
log "     sudo dd if=$OUTPUT_DIR/n900/u-boot.img of=/dev/sdX bs=384k seek=1"
log "  2. Or use flasher tool: flasher-3.5 -f -F $OUTPUT_DIR/n900/u-boot.img"