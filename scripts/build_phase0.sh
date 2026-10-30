#!/bin/bash
# Meridian OS - Phase 0 Master Build Script
# Executes complete Phase 0 build pipeline

set -euo pipefail

SCRIPT_DIR="/home/tiagoadg/Codes/tantoniazi/meridian-os/scripts"
BUILD_DIR="/home/tiagoadg/Codes/tantoniazi/meridian-os/build"
OUTPUT_DIR="/home/tiagoadg/Codes/tantoniazi/meridian-os/build/output"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Check dependencies
check_deps() {
    step "Checking dependencies..."
    local deps=("kas" "debootstrap" "ostree" "mmdebstrap" "qemu-user-static" "binfmt-support" 
                "arm-linux-gnueabihf-gcc" "u-boot-tools" "dtc" "mkimage" "kas")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            warn "Missing dependency: $dep"
        fi
    done
    log "Dependencies checked"
}

# Phase 0.1: Build kernel
build_kernel() {
    step "Building OMAP3 kernel..."
    bash "$SCRIPT_DIR/build_kernel.sh"
    log "Kernel build complete"
}

# Phase 0.2: Build U-Boot
build_uboot() {
    step "Building U-Boot for N900/N9..."
    bash "$SCRIPT_DIR/build_u_boot.sh"
    log "U-Boot build complete"
}

# Phase 0.3: Bootstrap rootfs with OSTree
bootstrap_rootfs() {
    step "Bootstrapping Debian trixie rootfs with OSTree..."
    bash "$SCRIPT_DIR/bootstrap_rootfs.sh"
    log "Rootfs bootstrap complete"
}

# Phase 0.4: Build images with KAS
build_images() {
    step "Building N900 image with KAS..."
    cd /home/tiagoadg/Codes/tantoniazi/meridian-os
    kas build build/meridian-n900.yml
    
    step "Building N9 image with KAS..."
    kas build build/meridian-n9.yml
    
    log "Image builds complete"
}

# Phase 0.5: Create bootable SD card image
create_sd_image() {
    step "Creating bootable SD card image..."
    
    local sd_img="$OUTPUT_DIR/meridian-n900-sd.img"
    local img_size="4G"
    
    # Create empty image
    dd if=/dev/zero of="$sd_img" bs=1M count=4096
    
    # Create partitions
    parted "$sd_img" --script mklabel msdos
    parted "$sd_img" --script mkpart primary fat32 1MiB 64MiB
    parted "$sd_img" --script mkpart primary ext4 64MiB 100%
    parted "$sd_img" --script set 1 boot on
    
    # Setup loop device
    local loop_dev=$(losetup --find --show --partscan "$sd_img")
    
    # Format partitions
    mkfs.vfat -F 32 -n "MERIDIAN_BOOT" "${loop_dev}p1"
    mkfs.ext4 -L "MERIDIAN_ROOT" "${loop_dev}p2"
    
    # Mount and copy bootloader
    local boot_mnt=$(mktemp -d)
    local root_mnt=$(mktemp -d)
    
    mount "${loop_dev}p1" "$boot_mnt"
    mount "${loop_dev}p2" "$root_mnt"
    
    # Copy U-Boot
    cp /home/tiagoadg/Codes/tantoniazi/meridian-os/build/output/u-boot/n900/MLO "$boot_mnt/"
    cp /home/tiagoadg/Codes/tantoniazi/meridian-os/build/output/u-boot/n900/u-boot.img "$boot_mnt/"
    cp /home/tiagoadg/Codes/tantoniazi/meridian-os/build/output/kernel/omap3/zImage "$boot_mnt/"
    cp /home/tiagoadg/Codes/tantoniazi/meridian-os/build/output/kernel/omap3/omap3-n900.dtb "$boot_mnt/"
    cp /home/tiagoadg/Codes/tantoniazi/meridian-os/build/output/kernel/omap3/omap3-n900.dtb "$boot_mnt/dtb"
    
    # Copy OSTree repo
    cp -r /home/tiagoadg/Codes/tantoniazi/meridian-os/build/tmp/deploy/ostree/repo "$root_mnt/ostree/"
    
    # Create boot script
    cat > "$boot_mnt/boot.scr" << 'EOF'
setenv fdtfile omap3-n900.dtb
setenv overlays "n900-keyboard n900-tvout"
setenv bootargs "console=ttyO2,115200 root=OSTREE=/ostree/deploy/meridian.ostree/0 ro quiet splash plymouth.ignore-serial-consoles"
load mmc 0:1 ${kernel_addr_r} /ostree/boot.1/zImage
load mmc 0:1 ${ramdisk_addr_r} /ostree/boot.1/initrd.img
load mmc 0:1 ${fdt_addr_r} /ostree/boot.1/omap3-n900.dtb
for overlay in ${overlays}; do
    load mmc 0:1 ${fdt_addr_r} /ostree/boot.1/overlays/${overlay}.dtbo
    fdt apply ${fdt_addr_r}
done
bootz ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}
EOF
    
    mkimage -A arm -O linux -T script -C none -n "Meridian Boot Script" -d "$boot_mnt/boot.scr" "$boot_mnt/boot.scr.uimg"
    
    # Unmount
    umount "$boot_mnt"
    umount "$root_mnt"
    losetup -d "$loop_dev"
    
    log "SD card image created at $sd_img"
}

# Main execution
main() {
    log "=== Meridian OS Phase 0 Build Pipeline ==="
    log "Target: Nokia N900/N9 (OMAP3)"
    log "Base: Debian trixie + OSTree"
    log ""
    
    check_deps
    
    # Execute phases
    build_kernel
    build_uboot
    bootstrap_rootfs
    build_images
    create_sd_image
    
    log ""
    log "=== Phase 0 Complete ==="
    log "Outputs:"
    log "  Kernel: build/output/kernel/omap3/"
    log "  U-Boot: build/output/u-boot/n900/ build/output/u-boot/n9/"
    log "  Rootfs: /tmp/meridian-rootfs"
    log "  OSTree: /tmp/meridian-ostree"
    log "  SD Image: build/output/meridian-n900-sd.img"
    log ""
    log "Next steps:"
    log "  1. Flash SD card: sudo dd if=build/output/meridian-n900-sd.img of=/dev/sdX bs=4M status=progress"
    log "  2. Insert SD into N900, boot"
    log "  3. Verify hardware bring-up (Phase 1)"
}

# Handle arguments
case "${1:-all}" in
    kernel)
        check_deps
        build_kernel
        ;;
    uboot)
        check_deps
        build_uboot
        ;;
    rootfs)
        check_deps
        bootstrap_rootfs
        ;;
    images)
        check_deps
        build_images
        ;;
    sd)
        check_deps
        create_sd_image
        ;;
    all)
        main
        ;;
    *)
        error "Usage: $0 {kernel|uboot|rootfs|images|sd|all}"
        ;;
esac