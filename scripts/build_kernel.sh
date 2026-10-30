#!/bin/bash
# Meridian OS - Build kernel for OMAP3 (N900/N9)

set -euo pipefail

KERNEL_DIR="/home/tiagoadg/Codes/tantoniazi/meridian-os/kernel"
BUILD_DIR="/tmp/meridian-kernel"
OUTPUT_DIR="/home/tiagoadg/Codes/tantoniazi/meridian-os/build/output/kernel"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check kernel source
if [[ ! -d "$KERNEL_DIR" ]]; then
    error "Kernel source directory not found at $KERNEL_DIR"
fi

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

log "Building kernel for OMAP3 (N900/N9)..."
cd "$KERNEL_DIR"

# Apply patches
if [[ -d "patches/omap3" && -f "patches/omap3/series" ]]; then
    log "Applying OMAP3 patches..."
    while IFS= read -r patch; do
        [[ "$patch" =~ ^#.*$ ]] && continue
        [[ -z "$patch" ]] && continue
        log "Applying patch: $patch"
        git apply "patches/omap3/$patch" || warn "Patch $patch may already be applied or failed"
    done < "patches/omap3/series"
fi

# Configure kernel
make O="$BUILD_DIR" ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- meridian-omap3_defconfig

# Build kernel
make -j$(nproc) O="$BUILD_DIR" ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
    zImage modules dtbs

# Copy artifacts
mkdir -p "$OUTPUT_DIR/omap3"
cp "$BUILD_DIR/arch/arm/boot/zImage" "$OUTPUT_DIR/omap3/"
cp "$BUILD_DIR/arch/arm/boot/dts/omap3-n900.dtb" "$OUTPUT_DIR/omap3/"
cp "$BUILD_DIR/arch/arm/boot/dts/omap3-n9.dtb" "$OUTPUT_DIR/omap3/"
cp "$BUILD_DIR/arch/arm/boot/dts/omap3-n950.dtb" "$OUTPUT_DIR/omap3/"
cp "$BUILD_DIR/arch/arm/boot/dts/omap3-n900.dtb" "$OUTPUT_DIR/omap3/omap3-n900.dtb"

# Copy modules
log "Installing modules..."
make O="$BUILD_DIR" ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
    INSTALL_MOD_PATH="$OUTPUT_DIR/omap3/rootfs" modules_install

# Create kernel package
log "Creating kernel package..."
cd "$OUTPUT_DIR/omap3"
tar -czf "linux-image-meridian-omap3_$(date +%Y%m%d)_armhf.tar.gz" \
    zImage \
    omap3-n900.dtb \
    omap3-n9.dtb \
    omap3-n950.dtb \
    rootfs/lib/modules/

log "OMAP3 kernel build complete!"
log "Output: $OUTPUT_DIR/omap3/"
log ""
log "Next steps:"
log "  1. Install kernel package to rootfs"
log "  2. Update bootloader scripts"
log "  3. Create OSTree commit with new kernel"