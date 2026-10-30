#!/bin/bash
# Meridian OS - Librem 5 Hardware Initialization
# Runs at early boot to initialize Librem 5-specific hardware

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[LIBREM5-INIT]${NC} $1"; }
warn() { echo -e "${YELLOW}[LIBREM5-INIT]${NC} $1"; }
error() { echo -e "${RED}[LIBREM5-INIT]${NC} $1"; }

# Check if running on Librem 5
check_hardware() {
    if [[ -f /proc/device-tree/model ]]; then
        if grep -q "Librem 5\|Purism Librem 5" /proc/device-tree/model 2>/dev/null; then
            log "Librem 5 hardware detected"
            return 0
        fi
    fi
    
    if [[ -f /proc/cpuinfo ]] && grep -q "i.MX8M\|i.MX 8M" /proc/cpuinfo; then
        log "i.MX8M detected (Librem 5)"
        return 0
    fi
    
    warn "Not running on Librem 5 hardware, skipping Librem 5-specific init"
    return 1
}

# Initialize PMIC (BD9571MWV)
init_pmic() {
    log "Initializing PMIC (BD9571MWV)..."
    
    # Load PMIC driver
    modprobe bd9571mwv 2>/dev/null || true
    
    # Enable regulators
    for reg in buck1 buck2 buck3 buck4 buck5 buck6 ldo1 ldo2 ldo3 ldo4 ldo5 ldo6 ldo7 ldo8; do
        if [[ -f /sys/class/regulator/$reg/enable ]]; then
            echo 1 > /sys/class/regulator/$reg/enable 2>/dev/null || true
        fi
    done
    
    log "PMIC initialized"
}

# Initialize display (etnaviv)
init_display() {
    log "Initializing display..."
    
    # Load GPU driver (etnaviv for Vivante GC7000Lite)
    modprobe etnaviv 2>/dev/null || true
    
    # Enable DRM/KMS
    echo 1 > /sys/class/display/drm/enable 2>/dev/null || true
    
    # Set display timings (720x1440)
    if [[ -f /sys/class/drm/card0/modes ]]; then
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

# Initialize modem (BM818)
init_modem() {
    log "Initializing modem (BM818)..."
    
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

# Initialize WiFi/Bluetooth (RS9116)
init_wifi_bt() {
    log "Initializing WiFi/Bluetooth (RS9116)..."
    
    # Load RS9116 driver
    modprobe rsi_91x 2>/dev/null || true
    modprobe rsi_usb 2>/dev/null || true
    modprobe rsi_sdio 2>/dev/null || true
    
    # Bluetooth
    modprobe btusb 2>/dev/null || true
    modprobe btintel 2>/dev/null || true
    
    # Start Bluetooth service
    systemctl start bluetooth 2>/dev/null || true
    
    # Start WiFi
    systemctl start wpa_supplicant 2>/dev/null || true
    
    log "WiFi/Bluetooth initialized"
}

# Initialize GPS (BM818 built-in GNSS)
init_gps() {
    log "Initializing GPS..."
    
    # Start gpsd
    systemctl start gpsd 2>/dev/null || true
    
    log "GPS initialized"
}

# Initialize camera (IMX258/OV5640)
init_camera() {
    log "Initializing camera..."
    
    # Load camera drivers
    modprobe imx258 2>/dev/null || true
    modprobe ov5640 2>/dev/null || true
    modprobe v4l2_fwnode 2>/dev/null || true
    modprobe mxc_v4l2_capture 2>/dev/null || true
    
    # Create video device nodes
    for i in 0 1 2; do
        if [[ ! -e /dev/video$i ]]; then
            mknod /dev/video$i c 81 $i 2>/dev/null || true
        fi
    done
    
    log "Camera initialized"
}

# Initialize audio (WM8960)
init_audio() {
    log "Initializing audio..."
    
    # Load audio drivers
    modprobe snd_soc_wm8960 2>/dev/null || true
    modprobe snd_soc_imx_audmux 2>/dev/null || true
    modprobe snd_soc_imx_ssi 2>/dev/null || true
    modprobe snd_soc_imx_hdmi 2>/dev/null || true
    
    # Configure ALSA
    alsactl restore 2>/dev/null || true
    
    # Set default volumes
    amixer -c 0 set Headphone 80% 2>/dev/null || true
    amixer -c 0 set Speaker 80% 2>/dev/null || true
    amixer -c 0 set "Main Mic" 50% 2>/dev/null || true
    
    log "Audio initialized"
}

# Initialize sensors (BMI160, AK09911)
init_sensors() {
    log "Initializing sensors..."
    
    # Accelerometer/Gyroscope (BMI160)
    modprobe bmi160_i2c 2>/dev/null || true
    modprobe bmi160_spi 2>/dev/null || true
    
    # Magnetometer (AK09911)
    modprobe ak09911 2>/dev/null || true
    
    # Proximity/ALS (VL53L0X)
    modprobe vl53l0x 2>/dev/null || true
    
    # Start sensorfw
    systemctl start sensorfw 2>/dev/null || true
    
    log "Sensors initialized"
}

# Initialize hardware kill switches
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
    
    # Create udev rules for switch events
    cat > /etc/udev/rules.d/99-librem5-killswitch.rules << 'EOF'
# Librem 5 hardware kill switches
ACTION=="change", SUBSYSTEM=="switch", RUN+="/usr/lib/librem5/killswitch-handler %k %s"
EOF
    
    log "Hardware kill switches initialized"
}

# Initialize hardware buttons (volume, power)
init_buttons() {
    log "Initializing hardware buttons..."
    
    # Load GPIO keys driver
    modprobe gpio_keys 2>/dev/null || true
    
    # Volume keys
    mkdir -p /sys/class/input/input-volume 2>/dev/null || true
    
    # Power key
    mkdir -p /sys/class/input/input-power 2>/dev/null || true
    
    log "Hardware buttons initialized"
}

# Initialize audio (WM8960)
init_audio() {
    log "Initializing audio..."
    
    # Load audio drivers
    modprobe snd_soc_wm8960 2>/dev/null || true
    modprobe snd_soc_imx_audmux 2>/dev/null || true
    modprobe snd_soc_imx_ssi 2>/dev/null || true
    modprobe snd_soc_imx_hdmi 2>/dev/null || true
    
    # Configure ALSA
    alsactl restore 2>/dev/null || true
    
    # Set default volumes
    amixer -c 0 set Headphone 80% 2>/dev/null || true
    amixer -c 0 set Speaker 80% 2>/dev/null || true
    amixer -c 0 set "Main Mic" 50% 2>/dev/null || true
    
    log "Audio initialized"
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

# Initialize hardware buttons (volume, power)
init_buttons() {
    log "Initializing hardware buttons..."
    
    # Load GPIO keys driver
    modprobe gpio_keys 2>/dev/null || true
    
    # Volume keys
    mkdir -p /sys/class/input/input-volume 2>/dev/null || true
    
    # Power key
    mkdir -p /sys/class/input/input-power 2>/dev/null || true
    
    log "Hardware buttons initialized"
}

# Initialize hardware kill switches
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
    
    # Create udev rules for switch events
    cat > /etc/udev/rules.d/99-librem5-killswitch.rules << 'EOF'
# Librem 5 hardware kill switches
ACTION=="change", SUBSYSTEM=="switch", RUN+="/usr/lib/librem5/killswitch-handler %k %s"
EOF
    
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

# Main initialization sequence
main() {
    log "Starting Librem 5 hardware initialization..."
    
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
    init_buttons
    init_pm
    
    log "Librem 5 hardware initialization complete!"
}

# Run main
main "$@"