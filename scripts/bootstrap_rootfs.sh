#!/bin/bash
# Meridian OS - Bootstrap Debian trixie rootfs with OSTree
# This script creates a minimal Debian trixie rootfs and sets up OSTree

set -euo pipefail

# Configuration
DISTRO="trixie"
ARCH="armhf"
ROOTFS_DIR="/tmp/meridian-rootfs"
OSTREE_REPO="/tmp/meridian-ostree"
MIRROR="http://deb.debian.org/debian"
VARIANT="minbase"
COMPONENTS="main,contrib,non-free-firmware"

# Meridian-specific packages
MERIDIAN_PACKAGES=(
    "meridian-base"
    "meridian-kernel-omap3"
    "meridian-shell"
    "meridian-home"
    "meridian-settings"
    "meridian-dialer"
    "meridian-messages"
    "meridian-contacts"
    "meridian-camera"
    "meridian-browser"
    "meridian-file-manager"
    "meridian-terminal"
    "meridian-store"
    "flatpak"
    "ostree"
    "systemd"
    "pipewire"
    "wireplumber"
    "modemmanager"
    "network-manager"
    "bluez"
    "gpsd"
    "sensorfw"
    "libcamera"
    "libcamera-tools"
    "mesa"
    "mesa-vulkan-drivers"
    "vulkan-tools"
    "weston"
    "maliit-keyboard"
    "maliit-plugins"
    "kirigami-addons"
    "qt6-declarative"
    "qt6-quick3d"
    "qt6-multimedia"
    "gtk4"
    "libadwaita-1"
    "xwayland"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root"
done

# Check dependencies
check_deps() {
    local deps=("debootstrap" "ostree" "qemu-user-static" "binfmt-support" "mmdebstrap")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error "Missing dependency: $dep"
        fi
    done
}

# Create minimal rootfs using mmdebstrap (faster than debootstrap)
create_rootfs() {
    log "Creating rootfs using mmdebstrap..."
    
    # Clean previous run
    rm -rf "$ROOTFS_DIR"
    mkdir -p "$ROOTFS_DIR"
    
    # Create package list
    local pkg_list="${MERIDIAN_PACKAGES[*]}"
    
    mmdebstrap \
        --architectures="$ARCH" \
        --variant="$VARIANT" \
        --components="$COMPONENTS" \
        --include="$pkg_list" \
        --hook-dir=/usr/share/mmdebstrap/hooks \
        --customize-hook="echo 'meridian' > \$1/etc/hostname" \
        --customize-hook="echo '127.0.0.1 localhost meridian' > \$1/etc/hosts" \
        --customize-hook="echo 'root:meridian' | chroot \$1 chpasswd" \
        --customize-hook="chroot \$1 systemctl enable systemd-networkd systemd-resolved" \
        --customize-hook="chroot \$1 systemctl enable ModemManager" \
        --customize-hook="chroot \$1 systemctl enable bluetooth" \
        --customize-hook="chroot \$1 systemctl enable NetworkManager" \
        --customize-hook="chroot \$1 systemctl enable wpa_supplicant" \
        --customize-hook="chroot \$1 systemctl enable gpsd" \
        --customize-hook="chroot \$1 systemctl enable ofono" \
        --customize-hook="chroot \$1 systemctl enable weston" \
        --customize-hook="chroot \$1 systemctl enable maliit-keyboard" \
        --customize-hook="chroot \$1 systemctl enable flatpak-system-helper" \
        --customize-hook="chroot \$1 systemctl enable ostree-remount" \
        --customize-hook="echo 'LANG=en_US.UTF-8' > \$1/etc/locale.conf" \
        --customize-hook="echo 'en_US.UTF-8 UTF-8' > \$1/etc/locale.gen" \
        --customize-hook="chroot \$1 locale-gen" \
        --customize-hook="echo 'UTC' > \$1/etc/timezone" \
        --customize-hook="ln -sf /usr/share/zoneinfo/UTC \$1/etc/localtime" \
        --customize-hook="mkdir -p \$1/ostree/deploy/meridian.ostree" \
        --customize-hook="mkdir -p \$1/var" \
        --customize-hook="mkdir -p \$1/home" \
        "$DISTRO" \
        "$ROOTFS_DIR" \
        "$MIRROR"
    
    log "Rootfs created at $ROOTFS_DIR"
}

# Initialize OSTree repository
init_ostree_repo() {
    log "Initializing OSTree repository..."
    
    rm -rf "$OSTREE_REPO"
    mkdir -p "$OSTREE_REPO"
    
    ostree --repo="$OSTREE_REPO" init --mode=archive-z2
    
    log "OSTree repository initialized at $OSTREE_REPO"
}

# Commit rootfs to OSTree
commit_ostree() {
    log "Committing rootfs to OSTree..."
    
    local commit_subject="Meridian OS $(date +%Y%m%d) - Initial bootstrap"
    
    ostree --repo="$OSTREE_REPO" commit \
        --branch=meridian/phone-n900 \
        --subject="$commit_subject" \
        --body="Initial bootstrap of Meridian OS for N900" \
        --tree=dir="$ROOTFS_DIR" \
        --add-metadata-string="version=$(date +%Y%m%d)" \
        --add-metadata-string="arch=armhf" \
        --add-metadata-string="device=n900" \
        --add-metadata-string="variant=phone"
    
    log "OSTree commit created"
}

# Generate bootloader files (kernel, initramfs, device tree)
generate_bootloader_files() {
    log "Generating bootloader files..."
    
    local boot_dir="$ROOTFS_DIR/ostree/boot.1"
    mkdir -p "$boot_dir"
    
    # Copy kernel, initramfs, and device tree from rootfs
    if [[ -f "$ROOTFS_DIR/boot/vmlinuz-"* ]]; then
        cp "$ROOTFS_DIR/boot/vmlinuz-"* "$boot_dir/vmlinuz"
    fi
    
    if [[ -f "$ROOTFS_DIR/boot/initrd.img-"* ]]; then
        cp "$ROOTFS_DIR/boot/initrd.img-"* "$boot_dir/initrd.img"
    fi
    
    if [[ -f "$ROOTFS_DIR/boot/dtbs/omap3-n900.dtb" ]]; then
        cp "$ROOTFS_DIR/boot/dtbs/omap3-n900.dtb" "$boot_dir/dtb"
    fi
    
    # Create boot script
    cat > "$boot_dir/boot.scr" << 'EOF'
setenv fdtfile omap3-n900.dtb
setenv overlays "n900-keyboard n900-tvout"
setenv bootargs "console=ttyO2,115200 root=OSTREE=/ostree/deploy/meridian.ostree/0 ro quiet splash plymouth.ignore-serial-consoles"
load mmc 0:1 ${kernel_addr_r} /ostree/boot.1/vmlinuz
load mmc 0:1 ${ramdisk_addr_r} /ostree/boot.1/initrd.img
load mmc 0:1 ${fdt_addr_r} /ostree/boot.1/dtb
for overlay in ${overlays}; do
    load mmc 0:1 ${fdt_addr_r} /ostree/boot.1/overlays/${overlay}.dtbo
    fdt apply ${fdt_addr_r}
done
bootz ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}
EOF
    
    # Compile boot script
    mkimage -A arm -O linux -T script -C none -n "Meridian Boot Script" -d "$boot_dir/boot.scr" "$boot_dir/boot.scr.uimg"
    
    log "Bootloader files generated at $boot_dir"
}

# Create OSTree summary
create_ostree_summary() {
    log "Creating OSTree summary..."
    
    ostree --repo="$OSTREE_REPO" summary -u
    
    log "OSTree summary created"
}

# Main execution
main() {
    log "Starting Meridian OS bootstrap for N900/N9..."
    
    check_deps
    create_rootfs
    init_ostree_repo
    commit_ostree
    generate_bootloader_files
    create_ostree_summary
    
    log "Bootstrap complete!"
    log "Rootfs: $ROOTFS_DIR"
    log "OSTree repo: $OSTREE_REPO"
    log ""
    log "Next steps:"
    log "  1. Build kernel: make -C kernel O=../build/kernel meridian-omap3_defconfig"
    log "  2. Build U-Boot: make -C bootloader/u-boot meridian_n900_defconfig"
    log "  3. Create image: kas build build/meridian.yml:phone-n900"
}

main "$@"