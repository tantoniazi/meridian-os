#!/bin/bash
# Meridian OS - N900 Hardware Initialization
# Runs at early boot to initialize N900-specific hardware

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[N900-INIT]${NC} $1"; }
warn() { echo -e "${YELLOW}[N900-INIT]${NC} $1"; }
error() { echo -e "${RED}[N900-INIT]${NC} $1"; }

# Check if running on N900
check_hardware() {
    if [[ ! -f /proc/device-tree/model ]] || ! grep -q "Nokia N900" /proc/device-tree/model 2>/dev/null; then
        # Fallback check
        if [[ ! -f /proc/cpuinfo ]] || ! grep -q "OMAP3" /proc/cpuinfo; then
            warn "Not running on N900 hardware, skipping N900-specific init"
            return 1
        fi
    fi
    log "N900 hardware detected"
    return 0
}

# Initialize TPS65950 PMIC
init_tps65950() {
    log "Initializing TPS65950 PMIC..."
    
    # Enable regulators
    for reg in vaux1 vaux2 vaux3 vaux4 vmmc1 vmmc2 vdac vio vpll vdd1 vdd2 vusb vdac; do
        if [[ -f /sys/class/regulator/$reg/enable ]]; then
            echo 1 > /sys/class/regulator/$reg/enable 2>/dev/null || true
        fi
    done
    
    # Set voltage levels for critical rails
    echo 1800000 > /sys/class/regulator/vdac/microvolts 2>/dev/null || true
    echo 3300000 > /sys/class/regulator/vio/microvolts 2>/dev/null || true
    
    log "TPS65950 PMIC initialized"
}

# Initialize display subsystem
init_display() {
    log "Initializing display subsystem..."
    
    # Enable DSS (Display Subsystem)
    echo 1 > /sys/class/display/omapdss/enable 2>/dev/null || true
    
    # Set display timings for N900 (800x480)
    if [[ -f /sys/class/drm/card0/modes ]]; then
        echo "800x480" > /sys/class/drm/card0/modes 2>/dev/null || true
    fi
    
    # Enable backlight
    echo 255 > /sys/class/backlight/omap3-backlight/brightness 2>/dev/null || true
    
    log "Display initialized"
}

# Initialize touchscreen (TSL2563/TSL2771)
init_touchscreen() {
    log "Initializing touchscreen..."
    
    # Load touchscreen driver
    modprobe tsc2007 2>/dev/null || true
    modprobe tps65950_ts 2>/dev/null || true
    
    # Calibration (if calibration data exists)
    if [[ -f /etc/pointercal ]]; then
        export TSLIB_CALIBFILE=/etc/pointercal
        export TSLIB_TSDEVICE=/dev/input/touchscreen0
    fi
    
    log "Touchscreen initialized"
}

# Initialize hardware keyboard
init_keyboard() {
    log "Initializing hardware keyboard..."
    
    # Load keyboard driver
    modprobe tps65950_keypad 2>/dev/null || true
    modprobe gpio_keys 2>/dev/null || true
    
    # Set keyboard layout
    if [[ -f /usr/share/keymaps/n900.kmap ]]; then
        loadkeys /usr/share/keymaps/n900.kmap 2>/dev/null || true
    fi
    
    log "Hardware keyboard initialized"
}

# Initialize USB OTG
init_usb_otg() {
    log "Initializing USB OTG..."
    
    # Enable musb-hdrc
    echo peripheral > /sys/class/usb_otg/otg0/mode 2>/dev/null || true
    
    # Enable USB networking
    modprobe g_ether 2>/dev/null || true
    modprobe g_serial 2>/dev/null || true
    modprobe g_mass_storage 2>/dev/null || true
    
    log "USB OTG initialized"
}

# Initialize TV-out
init_tvout() {
    log "Initializing TV-out..."
    
    # Enable DAC for composite video
    if [[ -f /sys/class/display/omapdss/tvout/enable ]]; then
        echo 1 > /sys/class/display/omapdss/tvout/enable 2>/dev/null || true
    fi
    
    # Set TV standard (PAL/NTSC)
    echo PAL > /sys/class/display/omapdss/tvout/standard 2>/dev/null || true
    
    log "TV-out initialized"
}

# Initialize FM radio
init_fm() {
    log "Initializing FM radio..."
    
    # Load FM driver (WL1271/FM)
    modprobe wl1271_fm 2>/dev/null || true
    
    # Set region (Europe/US/Japan)
    echo europe > /sys/class/radio/fm/region 2>/dev/null || true
    
    log "FM radio initialized"
}

# Initialize GPS
init_gps() {
    log "Initializing GPS..."
    
    # Start gpsd with N900 GPS device
    if [[ -c /dev/gps0 ]]; then
        systemctl start gpsd 2>/dev/null || true
    fi
    
    log "GPS initialized"
}

# Initialize camera
init_camera() {
    log "Initializing camera..."
    
    # Load camera drivers
    modprobe mt9t111 2>/dev/null || true
    modprobe omap3_camera 2>/dev/null || true
    
    # Create video device nodes
    for i in 0 1 2; do
        if [[ ! -e /dev/video$i ]]; then
            mknod /dev/video$i c 81 $i 2>/dev/null || true
        fi
    done
    
    log "Camera initialized"
}

# Initialize cellular modem (HSI)
init_modem() {
    log "Initializing cellular modem (HSI)..."
    
    # Load HSI driver
    modprobe hsi_char 2>/dev/null || true
    modprobe ti_hsi 2>/dev/null || true
    
    # Start ofono
    systemctl start ofono 2>/dev/null || true
    
    # Wait for modem to appear
    local timeout=30
    while [[ $timeout -gt 0 ]]; do
        if mmcli -L 2>/dev/null | grep -q "modem"; then
            log "Modem detected"
            break
        fi
        sleep 1
        ((timeout--))
    done
    
    if [[ $timeout -eq 0 ]]; then
        warn "Modem not detected within timeout"
    else
        log "Cellular modem initialized"
    fi
}

# Initialize audio (TPS65950/TWL4030)
init_audio() {
    log "Initializing audio..."
    
    # Load audio drivers
    modprobe snd_soc_tps65950 2>/dev/null || true
    modprobe snd_soc_twl4030 2>/dev/null || true
    modprobe snd_soc_omap3 2>/dev/null || true
    
    # Configure ALSA
    alsactl restore 2>/dev/null || true
    
    # Set default volumes
    amixer -c 0 set Headphone 80% 2>/dev/null || true
    amixer -c 0 set Speaker 80% 2>/dev/null || true
    amixer -c 0 set "Main Mic" 50% 2>/dev/null || true
    
    log "Audio initialized"
}

# Initialize sensors
init_sensors() {
    log "Initializing sensors..."
    
    # Accelerometer (LIS331)
    modprobe lis331 2>/dev/null || true
    modprobe lis3_i2c 2>/dev/null || true
    
    # Magnetometer (HMC5843)
    modprobe hmc5843 2>/dev/null || true
    
    # Gyroscope (L3G4200D)
    modprobe l3g4200d 2>/dev/null || true
    
    # Start sensorfw
    systemctl start sensorfw 2>/dev/null || true
    
    log "Sensors initialized"
}

# Initialize FM radio
init_fm() {
    log "Initializing FM radio..."
    
    # Load FM driver (WL1271/FM)
    modprobe wl1271_fm 2>/dev/null || true
    
    # Set region (Europe/US/Japan)
    echo europe > /sys/class/radio/fm/region 2>/dev/null || true
    
    log "FM radio initialized"
}

# Initialize power management
init_pm() {
    log "Initializing power management..."
    
    # Enable CPU frequency scaling
    echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || true
    
    # Enable runtime PM
    echo auto > /sys/bus/i2c/devices/*/power/control 2>/dev/null || true
    echo auto > /sys/bus/spi/devices/*/power/control 2>/dev/null || true
    echo auto > /sys/bus/platform/devices/*/power/control 2>/dev/null || true
    
    # Configure suspend
    echo mem > /sys/power/state 2>/dev/null || true
    
    log "Power management initialized"
}

# Main initialization sequence
main() {
    log "Starting N900 hardware initialization..."
    
    check_hardware || exit 0
    
    init_tps65950
    init_display
    init_touchscreen
    init_keyboard
    init_usb_otg
    init_tvout
    init_fm
    init_gps
    init_camera
    init_modem
    init_audio
    init_sensors
    init_pm
    
    log "N900 hardware initialization complete!"
}

# Run main
main "$@"