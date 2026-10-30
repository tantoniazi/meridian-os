#!/bin/bash
# Meridian OS - Suspend/Resume Hooks
# Handles device-specific suspend/resume operations

set -euo pipefail

ACTION="${1:-}"
DEVICE="${2:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[PM-HOOKS]${NC} $1"; }
warn() { echo -e "${YELLOW}[PM-HOOKS]${NC} $1"; }
error() { echo -e "${RED}[PM-HOOKS]${NC} $1"; }

# Device-specific suspend
suspend_device() {
    local device="$1"
    
    case "$device" in
        modem)
            log "Suspending modem..."
            mmcli -m any --disable 2>/dev/null || true
            ;;
        wifi)
            log "Suspending WiFi..."
            rfkill block wifi 2>/dev/null || true
            ;;
        bluetooth)
            log "Suspending Bluetooth..."
            rfkill block bluetooth 2>/dev/null || true
            ;;
        gps)
            log "Suspending GPS..."
            systemctl stop gpsd 2>/dev/null || true
            ;;
        camera)
            log "Suspending camera..."
            # Camera is suspended by kernel automatically
            ;;
        sensors)
            log "Suspending sensors..."
            systemctl stop sensorfw 2>/dev/null || true
            ;;
        audio)
            log "Suspending audio..."
            # Audio suspended by pipewire automatically
            ;;
        display)
            log "Suspending display..."
            # Turn off backlight
            for bl in /sys/class/backlight/*/bl_power; do
                echo 1 > "$bl" 2>/dev/null || true
            done
            ;;
        modem)
            log "Suspending modem..."
            mmcli -m any --disable 2>/dev/null || true
            ;;
        *)
            warn "Unknown device: $device"
            ;;
    esac
}

# Device-specific resume
resume_device() {
    local device="$1"
    
    case "$device" in
        modem)
            log "Resuming modem..."
            mmcli -m any --enable 2>/dev/null || true
            ;;
        wifi)
            log "Resuming WiFi..."
            rfkill unblock wifi 2>/dev/null || true
            ;;
        bluetooth)
            log "Resuming Bluetooth..."
            rfkill unblock bluetooth 2>/dev/null || true
            ;;
        gps)
            log "Resuming GPS..."
            systemctl start gpsd 2>/dev/null || true
            ;;
        camera)
            log "Resuming camera..."
            # Camera resumed by kernel automatically
            ;;
        sensors)
            log "Resuming sensors..."
            systemctl start sensorfw 2>/dev/null || true
            ;;
        audio)
            log "Resuming audio..."
            # Audio resumed by pipewire automatically
            ;;
        display)
            log "Resuming display..."
            # Turn on backlight
            for bl in /sys/class/backlight/*/bl_power; do
                echo 0 > "$bl" 2>/dev/null || true
            done
            ;;
        *)
            warn "Unknown device: $device"
            ;;
    esac
}

# Pre-suspend hook
pre_suspend() {
    log "Running pre-suspend hooks..."
    
    # Save current power profile
    if [[ -f /run/meridian/current-profile ]]; then
        cp /run/meridian/current-profile /run/meridian/suspended-profile
    fi
    
    # Set ultra-powersave for suspend
    /usr/lib/meridian/meridian-pm-manager set ultra-powersave
    
    # Sync filesystems
    sync
    
    # Flush disk caches
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    
    # Unmount network filesystems
    umount -a -t nfs,cifs,fuse.sshfs 2>/dev/null || true
    
    log "Pre-suspend hooks completed"
}

# Post-resume hook
post_resume() {
    log "Running post-resume hooks..."
    
    # Restore power profile
    if [[ -f /run/meridian/suspended-profile ]]; then
        local profile=$(cat /run/meridian/suspended-profile)
        /usr/lib/meridian/meridian-pm-manager set "$profile"
        rm -f /run/meridian/suspended-profile
    fi
    
    # Restart critical services
    systemctl restart NetworkManager 2>/dev/null || true
    systemctl restart ModemManager 2>/dev/null || true
    systemctl restart bluetooth 2>/dev/null || true
    
    # Re-apply power profile
    if [[ -f /run/meridian/current-profile ]]; then
        local profile=$(cat /run/meridian/current-profile)
        /usr/lib/meridian/meridian-pm-manager set "$profile"
    fi
    
    # Re-apply display brightness
    if [[ -f /run/meridian/brightness ]]; then
        local brightness=$(cat /run/meridian/brightness)
        for bl in /sys/class/backlight/*/brightness; do
            if [[ -f "$bl" ]]; then
                echo "$brightness" > "$bl" 2>/dev/null || true
            fi
        done
    fi
    
    log "Post-resume hooks completed"
}

# Hibernate pre-suspend
pre_hibernate() {
    log "Running pre-hibernate hooks..."
    
    # Save current state
    pre_suspend
    
    # Ensure swap is large enough
    local swap_size=$(free | awk '/^Swap:/ {print $2}')
    local mem_size=$(free | awk '/^Mem:/ {print $2}')
    
    if [[ $swap_size -lt $mem_size ]]; then
        warn "Swap size ($swap_size) < RAM size ($mem_size), hibernate may fail"
    fi
    
    log "Pre-hibernate hooks completed"
}

# Post-hibernate (resume from hibernate)
post_hibernate() {
    log "Running post-hibernate hooks..."
    post_resume
    log "Post-hibernate hooks completed"
}

# Main dispatcher
main() {
    local action="${1:-}"
    local device="${2:-}"
    
    case "$action" in
        suspend|pre-suspend)
            pre_suspend
            ;;
        resume|post-resume)
            post_resume
            ;;
        hibernate|pre-hibernate)
            pre_hibernate
            ;;
        thaw|post-hibernate)
            post_hibernate
            ;;
        suspend-device)
            suspend_device "$device"
            ;;
        resume-device)
            resume_device "$device"
            ;;
        *)
            echo "Usage: $0 {suspend|resume|hibernate|thaw|suspend-device|resume-device} [device]"
            exit 1
            ;;
    esac
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[PM-HOOKS]${NC} $1"; }
warn() { echo -e "${YELLOW}[PM-HOOKS]${NC} $1"; }
error() { echo -e "${RED}[PM-HOOKS]${NC} $1"; }

# Run main
main "$@"