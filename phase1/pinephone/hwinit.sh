#!/bin/bash
# Meridian OS - PinePhone/PinePhone Pro Hardware Initialization
# Runs at early boot to initialize PinePhone-specific hardware

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[PINEPHONE-INIT]${NC} $1"; }
warn() { echo -e "${YELLOW}[PINEPHONE-INIT]${NC} $1"; }
error() { echo -e "${RED}[PINEPHONE-INIT]${NC} $1"; }

# Check if running on PinePhone
check_hardware() {
    if [[ -f /proc/device-tree/model ]]; then
        if grep -q "PinePhone\|PinePhone Pro" /proc/device-tree/model 2>/dev/null; then
            log "PinePhone hardware detected"
            return 0
        fi
    fi
    
    if [[ -f /proc/cpuinfo ]] && grep -q "Allwinner\|Rockchip" /proc/cpuinfo; then
        log "Allwinner/Rockchip detected (PinePhone)"
        return 0
    fi
    
    warn "Not running on PinePhone hardware, skipping PinePhone-specific init"
    return 1
}

# Detect PinePhone model
detect_model() {
    if grep -q "PinePhone Pro" /proc/device-tree/model 2>/dev/null; then
        echo "pinephonepro"
    elif grep -q "PinePhone" /proc/device-tree/model 2>/dev/null; then
        echo "pinephone"
    elif grep -q "Allwinner A64" /proc/cpuinfo; then
        echo "pinephone"
    elif grep -q "Rockchip RK3399" /proc/cpuinfo; then
        echo "pinephonepro"
    else
        echo "unknown"
    fi
}

MODEL=$(detect_model)
log "Detected model: $MODEL"

# Initialize PMIC (AXP803 for PinePhone, AXP809 for PinePhone Pro)
init_pmic() {
    log "Initializing PMIC..."
    
    if [[ "$MODEL" == "pinephonepro" ]]; then
        # AXP809 for PinePhone Pro
        modprobe axp20x 2>/dev/null || true
        modprobe axp20x_i2c 2>/dev/null || true
    else
        # AXP803 for PinePhone
        modprobe axp20x 2>/dev/null || true
        modprobe axp20x_i2c 2>/dev/null || true
    fi
    
    # Enable regulators
    for reg in aldo1 aldo2 aldo3 aldo4 bldo1 bldo2 bldo3 bldo4 cldo1 cldo2 cldo3 dldo1 dldo2; do
        if [[ -f /sys/class/regulator/$reg/enable ]]; then
            echo 1 > /sys/class/regulator/$reg/enable 2>/dev/null || true
        fi
    done
    
    log "PMIC initialized"
}

# Initialize display (Lima/Panfrost)
init_display() {
    log "Initializing display..."
    
    # Load GPU driver
    if [[ "$MODEL" == "pinephonepro" ]]; then
        modprobe panfrost 2>/dev/null || true
    else
        modprobe lima 2>/dev/null || true
    fi
    
    # Enable DRM/KMS
    echo 1 > /sys/class/display/drm/enable 2>/dev/null || true
    
    # Set display timings (720x1440 for PinePhone, 1440x720 for Pro)
    if [[ "$MODEL" == "pinephonepro" ]]; then
        echo "1440x720" > /sys/class/drm/card0/modes 2>/dev/null || true
    else
        echo "720x1440" > /sys/class/drm/card0/modes 2>/dev/null || true
    fi
    
    # Enable backlight
    echo 255 > /sys/class/backlight/backlight/brightness 2>/dev/null || true
    
    log "Display initialized"
}

# Initialize touchscreen (Goodix)
init_touchscreen() {
    log "Initializing touchscreen..."
    
    # Load Goodix driver
    modprobe goodix 2>/dev/null || true
    
    # Load firmware if needed
    if [[ -f /lib/firmware/goodix/goodix_firmware.bin ]]; then
        cp /lib/firmware/goodix/goodix_firmware.bin /lib/firmware/ 2>/dev/null || true
    fi
    
    log "Touchscreen initialized"
}

# Initialize modem (Quectel EG25)
init_modem() {
    log "Initializing modem (Quectel EG25)..."
    
    # Load USB serial drivers
    modprobe usbserial 2>/dev/null || true
    modprobe option 2>/dev/null || true
    modprobe qmi_wwan 2>/dev/null || true
    modprobe cdc_acm 2>/dev/null || true
    modprobe cdc_wdm 2>/dev/null || true
    modprobe cdc_mbim 2>/dev/null || true
    
    # Power on modem (GPIO)
    if [[ -f /sys/class/gpio/gpioXX/value ]]; then
        echo 1 > /sys/class/gpio/gpioXX/value 2>/dev/null || true
    fi
    
    # Start ModemManager
    systemctl start ModemManager 2>/dev/null || true
    
    # Wait for modem
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
        log "Modem initialized"
    fi
}

# Initialize WiFi/Bluetooth (RTL8723CS)
init_wifi_bt() {
    log "Initializing WiFi/Bluetooth..."
    
    # Load RTL8723CS driver
    modprobe rtl8723cs 2>/dev/null || true
    
    # Load Bluetooth
    modprobe btusb 2>/dev/null || true
    modprobe btintel 2>/dev/null || true
    
    # Start Bluetooth service
    systemctl start bluetooth 2>/dev/null || true
    
    # Start WiFi
    systemctl start wpa_supplicant 2>/dev/null || true
    
    log "WiFi/Bluetooth initialized"
}

# Initialize GPS
init_gps() {
    log "Initializing GPS..."
    
    # Start gpsd
    systemctl start gpsd 2>/dev/null || true
    
    log "GPS initialized"
}

# Initialize camera (OV5640/GC2145)
init_camera() {
    log "Initializing camera..."
    
    # Load camera drivers
    modprobe ov5640 2>/dev/null || true
    modprobe gc2145 2>/dev/null || true
    modprobe v4l2_fwnode 2>/dev/null || true
    
    # Create video device nodes
    for i in 0 1 2; do
        if [[ ! -e /dev/video$i ]]; then
            mknod /dev/video$i c 81 $i 2>/dev/null || true
        fi
    done
    
    log "Camera initialized"
}

# Initialize audio (A64/RK3399 audio)
init_audio() {
    log "Initializing audio..."
    
    # Load audio drivers
    modprobe snd_soc_simple_card 2>/dev/null || true
    modprobe snd_soc_sun8i_codec_analog 2>/dev/null || true
    modprobe snd_soc_rk3399_gru_sound 2>/dev/null || true
    
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
    
    # Accelerometer (ST LSM6DSX)
    modprobe st_lsm6dsx 2>/dev/null || true
    modprobe st_lsm6dsx_i2c 2>/dev/null || true
    modprobe st_lsm6dsx_spi 2>/dev/null || true
    
    # Magnetometer (AK09911)
    modprobe ak09911 2>/dev/null || true
    
    # Proximity/ALS (LTR553)
    modprobe ltr553 2>/dev/null || true
    
    # Start sensorfw
    systemctl start sensorfw 2>/dev/null || true
    
    log "Sensors initialized"
}

# Initialize hardware switches (kill switches)
init_kill_switches() {
    log "Initializing hardware kill switches..."
    
    # Load GPIO keys driver
    modprobe gpio_keys 2>/dev/null || true
    
    # Create sysfs entries for switches
    for switch in modem wifi bt camera mic; do
        if [[ ! -e /sys/class/switch/$switch ]]; then
            mkdir -p /sys/class/switch/$switch 2>/dev/null || true
            echo 1 > /sys/class/switch/$switch/state 2>/dev/null || true
        fi
    done
    
    log "Hardware kill switches initialized"
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
    echo deep > /sys/power/mem_sleep 2>/dev/null || true
    
    log "Power management initialized"
}

# Initialize hardware switches (rear cover, etc.)
init_hardware_switches() {
    log "Initializing hardware switches..."
    
    # Rear cover switch
    modprobe gpio_keys 2>/dev/null || true
    
    # Volume keys
    modprobe gpio_keys 2>/dev/null || true
    
    # Power key
    modprobe gpio_keys 2>/dev/null || true
    
    log "Hardware switches initialized"
}

# Main initialization sequence
main() {
    log "Starting PinePhone hardware initialization..."
    
    check_hardware || exit 0
    
    init_pmic
    init_display
    init_touchscreen
    init_modem
    init_wifi_bt
    init_gps
    init_camera
    init_audio
    init_sensors
    init_kill_switches
    init_pm
    init_hardware_switches
    
    log "PinePhone hardware initialization complete!"
}

# Run main
main "$@"