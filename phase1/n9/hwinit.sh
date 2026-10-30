#!/bin/bash
# Meridian OS - N9/N950 Hardware Initialization
# Runs at early boot to initialize N9/N950-specific hardware

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[N9-INIT]${NC} $1"; }
warn() { echo -e "${YELLOW}[N9-INIT]${NC} $1"; }
error() { echo -e "${RED}[N9-INIT]${NC} $1"; }

# Check if running on N9/N950
check_hardware() {
    if [[ -f /proc/device-tree/model ]]; then
        if grep -q "Nokia N9\|Nokia N950" /proc/device-tree/model 2>/dev/null; then
            log "N9/N950 hardware detected"
            return 0
        fi
    fi
    
    if [[ -f /proc/cpuinfo ]] && grep -q "OMAP3630" /proc/cpuinfo; then
        log "OMAP3630 detected (N9/N950)"
        return 0
    fi
    
    warn "Not running on N9/N950 hardware, skipping N9-specific init"
    return 1
}

# Initialize TPS65950 PMIC (shared with N900)
init_tps65950() {
    log "Initializing TPS65950 PMIC..."
    
    # Enable regulators
    for reg in vaux1 vaux2 vaux3 vaux4 vmmc1 vmmc2 vdac vio vpll vdd1 vdd2 vusb vdac; do
        if [[ -f /sys/class/regulator/$reg/enable ]]; then
            echo 1 > /sys/class/regulator/$reg/enable 2>/dev/null || true
        fi
    done
    
    log "TPS65950 PMIC initialized"
}

# Initialize display subsystem
init_display() {
    log "Initializing display subsystem..."
    
    # Enable DSS (Display Subsystem)
    echo 1 > /sys/class/display/omapdss/enable 2>/dev/null || true
    
    # Set display timings for N9 (854x480)
    if [[ -f /sys/class/drm/card0/modes ]]; then
        echo "854x480" > /sys/class/drm/card0/modes 2>/dev/null || true
    fi
    
    # Enable backlight
    echo 255 > /sys/class/backlight/omap3-backlight/brightness 2>/dev/null || true
    
    log "Display initialized"
}

# Initialize touchscreen (Synaptics)
init_touchscreen() {
    log "Initializing touchscreen..."
    
    # Load touchscreen driver (Synaptics)
    modprobe synaptics_i2c 2>/dev/null || true
    modprobe synaptics_rmi4 2>/dev/null || true
    
    # Load firmware if needed
    if [[ -f /lib/firmware/synaptics/synaptics_rmi4.fw ]]; then
        cp /lib/firmware/synaptics/synaptics_rmi4.fw /lib/firmware/ 2>/dev/null || true
    fi
    
    log "Touchscreen initialized"
}

# Initialize hardware keyboard (N950 only)
init_keyboard() {
    log "Initializing hardware keyboard..."
    
    # Check if N950 (has hardware keyboard)
    if grep -q "N950" /proc/device-tree/model 2>/dev/null; then
        log "N950 detected, initializing hardware keyboard..."
        
        # Load keyboard driver
        modprobe tps65950_keypad 2>/dev/null || true
        modprobe gpio_keys 2>/dev/null || true
        
        # Set keyboard layout
        if [[ -f /usr/share/keymaps/n950.kmap ]]; then
            loadkeys /usr/share/keymaps/n950.kmap 2>/dev/null || true
        fi
        
        log "Hardware keyboard initialized"
    else
        log "N9 detected (no hardware keyboard)"
    fi
}

# Initialize USB
init_usb() {
    log "Initializing USB..."
    
    # Enable USB OTG
    echo peripheral > /sys/class/usb_otg/otg0/mode 2>/dev/null || true
    
    # Enable USB networking
    modprobe g_ether 2>/dev/null || true
    modprobe g_serial 2>/dev/null || true
    modprobe g_mass_storage 2>/dev/null || true
    
    # Enable USB host
    echo host > /sys/class/usb_otg/otg0/mode 2>/dev/null || true
    
    log "USB initialized"
}

# Initialize GPS
init_gps() {
    log "Initializing GPS..."
    
    # Start gpsd with N9 GPS device
    if [[ -c /dev/gps0 ]]; then
        systemctl start gpsd 2>/dev/null || true
    fi
    
    log "GPS initialized"
}

# Initialize camera
init_camera() {
    log "Initializing camera..."
    
    # Load camera drivers
    modprobe mt9t112 2>/dev/null || true
    modprobe omap3_camera 2>/dev/null || true
    
    # Create video device nodes
    for i in 0 1 2; do
        if [[ ! -e /dev/video$i ]]; then
            mknod /dev/video$i c 81 $i 2>/dev/null || true
        fi
    done
    
    log "Camera initialized"
}

# Initialize cellular modem (USB CDC/ACM + QRTR)
init_modem() {
    log "Initializing cellular modem (USB)..."
    
    # Load USB modem drivers
    modprobe usbserial 2>/dev/null || true
    modprobe option 2>/dev/null || true
    modprobe qmi_wwan 2>/dev/null || true
    modprobe cdc_acm 2>/dev/null || true
    modprobe cdc_wdm 2>/dev/null || true
    
    # Start ofono
    systemctl start ofono 2>/dev/null || true
    
    # Start ModemManager
    systemctl start ModemManager 2>/dev/null || true
    
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
    
    # Proximity/ALS (GP2A)
    modprobe gp2a 2>/dev/null || true
    
    # Start sensorfw
    systemctl start sensorfw 2>/dev/null || true
    
    log "Sensors initialized"
}

# Initialize WiFi/Bluetooth (WL1271)
init_wifi_bt() {
    log "Initializing WiFi/Bluetooth..."
    
    # Load WL1271 driver
    modprobe wl1271 2>/dev/null || true
    modprobe wl1271_sdio 2>/dev/null || true
    modprobe wlcore 2>/dev/null || true
    modprobe wlcore_sdio 2>/dev/null || true
    
    # Bluetooth
    modprobe btusb 2>/dev/null || true
    modprobe btrtl 2>/dev/null || true
    modprobe btintel 2>/dev/null || true
    
    # Start Bluetooth service
    systemctl start bluetooth 2>/dev/null || true
    
    log "WiFi/Bluetooth initialized"
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
    log "Starting N9/N950 hardware initialization..."
    
    check_hardware || exit 0
    
    init_tps65950
    init_display
    init_touchscreen
    init_keyboard
    init_usb
    init_gps
    init_camera
    init_modem
    init_audio
    init_sensors
    init_wifi_bt
    init_pm
    
    log "N9/N950 hardware initialization complete!"
}

# Run main
main "$@"