#!/bin/bash
# Meridian OS - Build kernel for multiple architectures (OMAP3, sunxi, etc.)

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

usage() {
    cat <<EOF
Usage: $0 [TARGET]

Targets:
  omap3     Build for OMAP3 (N900/N9/N950) - armhf
  sunxi     Build for Allwinner A64/sun50i (PinePhone) - arm64
  imx8      Build for NXP i.MX8MQ (Librem 5) - arm64
  all       Build all targets

Default: omap3
EOF
    exit 1
}

# Parse target
TARGET="${1:-omap3}"

# Validate target
case "$TARGET" in
    omap3|sunxi|imx8|all) ;;
    *) error "Unknown target: $TARGET. Use: omap3, sunxi, imx8, or all" ;;
esac

# Check kernel source
if [[ ! -d "$KERNEL_DIR" ]]; then
    error "Kernel source directory not found at $KERNEL_DIR"
fi

build_omap3() {
    local build_dir="$BUILD_DIR/omap3"
    local output_dir="$OUTPUT_DIR/omap3"
    
    log "Building kernel for OMAP3 (N900/N9)..."
    
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    mkdir -p "$output_dir"
    
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
    make O="$build_dir" ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- meridian-omap3_defconfig
    
    # Build kernel
    make -j$(nproc) O="$build_dir" ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
        zImage modules dtbs
    
    # Copy artifacts
    mkdir -p "$output_dir"
    cp "$build_dir/arch/arm/boot/zImage" "$output_dir/"
    cp "$build_dir/arch/arm/boot/dts/omap3-n900.dtb" "$output_dir/"
    cp "$build_dir/arch/arm/boot/dts/omap3-n9.dtb" "$output_dir/"
    cp "$build_dir/arch/arm/boot/dts/omap3-n950.dtb" "$output_dir/"
    cp "$build_dir/arch/arm/boot/dts/omap3-n900.dtb" "$output_dir/omap3-n900.dtb"
    
    # Copy modules
    log "Installing modules..."
    make O="$build_dir" ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
        INSTALL_MOD_PATH="$output_dir/rootfs" modules_install
    
    # Create kernel package
    log "Creating kernel package..."
    cd "$output_dir"
    tar -czf "linux-image-meridian-omap3_$(date +%Y%m%d)_armhf.tar.gz" \
        zImage \
        omap3-n900.dtb \
        omap3-n9.dtb \
        omap3-n950.dtb \
        rootfs/lib/modules/
    
    log "OMAP3 kernel build complete!"
    log "Output: $output_dir/"
}

build_sunxi() {
    local build_dir="$BUILD_DIR/sunxi"
    local output_dir="$OUTPUT_DIR/sunxi"
    
    log "Building kernel for Allwinner A64/sun50i (PinePhone)..."
    
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    mkdir -p "$output_dir"
    
    cd "$KERNEL_DIR"
    
    # Apply patches
    if [[ -d "patches/sunxi" && -f "patches/sunxi/series" ]]; then
        log "Applying sunxi patches..."
        while IFS= read -r patch; do
            [[ "$patch" =~ ^#.*$ ]] && continue
            [[ -z "$patch" ]] && continue
            log "Applying patch: $patch"
            git apply "patches/sunxi/$patch" || warn "Patch $patch may already be applied or failed"
        done < "patches/sunxi/series"
    fi
    
    # Configure kernel
    make O="$build_dir" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- meridian-sunxi_defconfig
    
    # Build kernel
    make -j$(nproc) O="$build_dir" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
        Image modules dtbs
    
    # Copy artifacts
    mkdir -p "$output_dir"
    cp "$build_dir/arch/arm64/boot/Image" "$output_dir/"
    cp "$build_dir/arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone.dtb" "$output_dir/"
    cp "$build_dir/arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone-pro.dtb" "$output_dir/"
    cp "$build_dir/arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone.dtb" "$output_dir/sun50i-a64-pinephone.dtb"
    
    # Copy modules
    log "Installing modules..."
    make O="$build_dir" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
        INSTALL_MOD_PATH="$output_dir/rootfs" modules_install
    
    # Create kernel package
    log "Creating kernel package..."
    cd "$output_dir"
    tar -czf "linux-image-meridian-sunxi_$(date +%Y%m%d)_arm64.tar.gz" \
        Image \
        sun50i-a64-pinephone.dtb \
        sun50i-a64-pinephone-pro.dtb \
        rootfs/lib/modules/
    
    log "sunxi (PinePhone) kernel build complete!"
    log "Output: $output_dir/"
}

build_imx8() {
    local build_dir="$BUILD_DIR/imx8"
    local output_dir="$OUTPUT_DIR/imx8"
    
    log "Building kernel for NXP i.MX8MQ (Librem 5)..."
    
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    mkdir -p "$output_dir"
    
    cd "$KERNEL_DIR"
    
    # Apply patches
    if [[ -d "patches/imx8" && -f "patches/imx8/series" ]]; then
        log "Applying i.MX8 patches..."
        while IFS= read -r patch; do
            [[ "$patch" =~ ^#.*$ ]] && continue
            [[ -z "$patch" ]] && continue
            log "Applying patch: $patch"
            git apply "patches/imx8/$patch" || warn "Patch $patch may already be applied or failed"
        done < "patches/imx8/series"
    fi
    
    # Configure kernel
    make O="$build_dir" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- meridian-imx8_defconfig
    
    # Build kernel
    make -j$(nproc) O="$build_dir" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
        Image modules dtbs
    
    # Copy artifacts
    mkdir -p "$output_dir"
    cp "$build_dir/arch/arm64/boot/Image" "$output_dir/"
    cp "$build_dir/arch/arm64/boot/dts/freescale/imx8mq-librem5.dtb" "$output_dir/"
    cp "$build_dir/arch/arm64/boot/dts/freescale/imx8mq-librem5.dtb" "$output_dir/imx8mq-librem5.dtb"
    
    # Copy modules
    log "Installing modules..."
    make O="$build_dir" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
        INSTALL_MOD_PATH="$output_dir/rootfs" modules_install
    
    # Create kernel package
    log "Creating kernel package..."
    cd "$output_dir"
    tar -czf "linux-image-meridian-imx8_$(date +%Y%m%d)_arm64.tar.gz" \
        Image \
        imx8mq-librem5.dtb \
        rootfs/lib/modules/
    
    log "i.MX8 (Librem 5) kernel build complete!"
    log "Output: $output_dir/"
}

# Build selected targets
case "$TARGET" in
    omap3)
        build_omap3
        ;;
    sunxi)
        build_sunxi
        ;;
    imx8)
        build_imx8
        ;;
    all)
        build_omap3
        build_sunxi
        build_imx8
        ;;
esac

log ""
log "Next steps:"
log "  1. Install kernel package to rootfs"
log "  2. Update bootloader scripts"
log "  3. Create OSTree commit with new kernel"