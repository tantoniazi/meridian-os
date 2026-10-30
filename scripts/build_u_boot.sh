#!/bin/bash
# Meridian OS - Build U-Boot for multiple targets (N900, N9, PinePhone)

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

usage() {
    cat <<EOF
Usage: $0 [TARGET]

Targets:
  n900      Build for Nokia N900 (OMAP3)
  n9        Build for Nokia N9/N950 (OMAP3)
  pinephone Build for PinePhone (Allwinner A64)
  all       Build all targets

Default: n900
EOF
    exit 1
}

# Parse target
TARGET="${1:-n900}"

# Validate target
case "$TARGET" in
    n900|n9|pinephone|all) ;;
    *) error "Unknown target: $TARGET. Use: n900, n9, pinephone, or all" ;;
esac

# Check if we're in the right place
if [[ ! -d "$UBOOT_DIR" ]]; then
    error "U-Boot source directory not found at $UBOOT_DIR"
fi

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

build_n900() {
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
}

build_n9() {
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
}

build_pinephone() {
    log "Building U-Boot for PinePhone (Allwinner A64)..."
    cd "$UBOOT_DIR"
    make O="$BUILD_DIR/pinephone" ARCH=arm CROSS_COMPILE=aarch64-linux-gnu- meridian_pinephone_defconfig
    make -j$(nproc) O="$BUILD_DIR/pinephone" ARCH=arm CROSS_COMPILE=aarch64-linux-gnu-

    # Copy artifacts
    mkdir -p "$OUTPUT_DIR/pinephone"
    cp "$BUILD_DIR/pinephone/u-boot.img" "$OUTPUT_DIR/pinephone/"
    cp "$BUILD_DIR/pinephone/u-boot.bin" "$OUTPUT_DIR/pinephone/"
    cp "$BUILD_DIR/pinephone/u-boot.scr" "$OUTPUT_DIR/pinephone/" 2>/dev/null || true
    cp "$BUILD_DIR/pinephone/u-boot-sunxi-with-spl.bin" "$OUTPUT_DIR/pinephone/" 2>/dev/null || true
    cp "$BUILD_DIR/pinephone/spl/sunxi-spl.bin" "$OUTPUT_DIR/pinephone/" 2>/dev/null || true

    log "PinePhone U-Boot built successfully at $OUTPUT_DIR/pinephone/"
}

# Build selected targets
case "$TARGET" in
    n900)
        build_n900
        ;;
    n9)
        build_n9
        ;;
    pinephone)
        build_pinephone
        ;;
    all)
        build_n900
        build_n9
        build_pinephone
        ;;
esac

log "U-Boot build complete!"
log "Output: $OUTPUT_DIR"
log ""
log "Next steps:"
log "  PinePhone: Flash u-boot-sunxi-with-spl.bin to SD card:"
log "     sudo dd if=$OUTPUT_DIR/pinephone/u-boot-sunxi-with-spl.bin of=/dev/sdX bs=8k seek=1"
log "  N900: Flash MLO and u-boot.img:"
log "     sudo dd if=$OUTPUT_DIR/n900/MLO of=/dev/sdX bs=128k seek=1"
log "     sudo dd if=$OUTPUT_DIR/n900/u-boot.img of=/dev/sdX bs=384k seek=1"