#!/bin/bash
# Meridian OS - Power Profile Manager
# Manages power profiles and applies system-wide power settings

set -euo pipefail

# Configuration file
CONFIG_FILE="/etc/meridian/pm.conf"
CURRENT_PROFILE_FILE="/run/meridian/current-profile"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[PM-MANAGER]${NC} $1"; }
warn() { echo -e "${YELLOW}[PM-MANAGER]${NC} $1"; }
error() { echo -e "${RED}[PM-MANAGER]${NC} $1"; }

# Load configuration
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    else
        error "Config file not found: $CONFIG_FILE"
    fi
}

# Get current profile
get_current_profile() {
    if [[ -f "$CURRENT_PROFILE_FILE" ]]; then
        cat "$CURRENT_PROFILE_FILE"
    else
        echo "balanced"
    fi
}

# Set profile
set_profile() {
    local profile="$1"
    
    case "$profile" in
        performance|balanced|powersave|ultra-powersave)
            ;;
        *)
            error "Invalid profile: $profile"
            ;;
    esac
    
    log "Setting power profile to: $profile"
    
    # Apply CPU governor
    apply_cpu_governor "$profile"
    
    # Apply GPU settings
    apply_gpu_settings "$profile"
    
    # Apply display settings
    apply_display_settings "$profile"
    
    # Apply radio settings
    apply_radio_settings "$profile"
    
    # Apply CPU frequency limits
    apply_cpu_limits "$profile"
    
    # Save current profile
    echo "$profile" > "$CURRENT_PROFILE_FILE"
    
    # Notify user
    notify-send "Power Profile" "Switched to $profile mode" --icon=preferences-system-power
    
    log "Power profile set to: $profile"
}

# Apply CPU governor
apply_cpu_governor() {
    local profile="$1"
    local governor=""
    
    case "$profile" in
        performance) governor="performance" ;;
        balanced) governor="ondemand" ;;
        powersave) governor="powersave" ;;
        ultra-powersave) governor="powersave" ;;
    esac
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$governor" > "$cpu" 2>/dev/null || true
    done
    
    log "CPU governor set to: $governor"
}

# Apply GPU settings
apply_gpu_settings() {
    local profile="$1"
    local powersaving=""
    
    case "$profile" in
        performance) powersaving="no" ;;
        balanced|powersave|ultra-powersave) powersaving="yes" ;;
    esac
    
    # AMD
    if [[ -f /sys/class/drm/card0/device/power_dpm_force_performance_level ]]; then
        if [[ "$powersaving" == "yes" ]]; then
            echo "auto" > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || true
        else
            echo "high" > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || true
        fi
    fi
    
    # Intel
    if [[ -f /sys/class/drm/card0/device/power_dpm_state ]]; then
        if [[ "$powersaving" == "yes" ]]; then
            echo "battery" > /sys/class/drm/card0/device/power_dpm_state 2>/dev/null || true
        else
            echo "performance" > /sys/class/drm/card0/device/power_dpm_state 2>/dev/null || true
        fi
    fi
    
    log "GPU power saving: $powersaving"
}

# Apply display settings
apply_display_settings() {
    local profile="$1"
    local brightness=""
    
    case "$profile" in
        performance) brightness="100%" ;;
        balanced) brightness="80%" ;;
        powersave) brightness="50%" ;;
        ultra-powersave) brightness="30%" ;;
    esac
    
    # Apply to all backlight devices
    for bl in /sys/class/backlight/*/brightness; do
        if [[ -f "$bl" ]]; then
            local max_brightness=$(cat "${bl%/brightness}/max_brightness" 2>/dev/null || echo 255)
            local new_brightness=0
            
            case "$brightness" in
                "100%") new_brightness=$max_brightness ;;
                "80%") new_brightness=$((max_brightness * 80 / 100)) ;;
                "50%") new_brightness=$((max_brightness * 50 / 100)) ;;
                "30%") new_brightness=$((max_brightness * 30 / 100)) ;;
            esac
            
            echo "$new_brightness" > "$bl" 2>/dev/null || true
        fi
    done
    
    log "Display brightness set to: $brightness"
}

# Apply radio settings
apply_radio_settings() {
    local profile="$1"
    
    case "$profile" in
        ultra-powersave)
            # Disable radios
            rfkill block bluetooth 2>/dev/null || true
            rfkill block wifi 2>/dev/null || true
            rfkill block wwan 2>/dev/null || true
            rfkill block gps 2>/dev/null || true
            
            # Disable services
            systemctl stop bluetooth 2>/dev/null || true
            systemctl stop wpa_supplicant 2>/dev/null || true
            systemctl stop ModemManager 2>/dev/null || true
            systemctl stop gpsd 2>/dev/null || true
            systemctl stop sensorfw 2>/dev/null || true
            ;;
        *)
            # Enable radios
            rfkill unblock bluetooth 2>/dev/null || true
            rfkill unblock wifi 2>/dev/null || true
            rfkill unblock wwan 2>/dev/null || true
            rfkill unblock gps 2>/dev/null || true
            
            # Enable services
            systemctl start bluetooth 2>/dev/null || true
            systemctl start wpa_supplicant 2>/dev/null || true
            systemctl start ModemManager 2>/dev/null || true
            systemctl start gpsd 2>/dev/null || true
            systemctl start sensorfw 2>/dev/null || true
            ;;
    esac
    
    log "Radio settings applied for: $profile"
}

# Apply CPU frequency limits
apply_cpu_limits() {
    local profile="$1"
    local max_freq_pct=""
    
    case "$profile" in
        performance) max_freq_pct="100%" ;;
        balanced) max_freq_pct="80%" ;;
        powersave) max_freq_pct="50%" ;;
        ultra-powersave) max_freq_pct="30%" ;;
    esac
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        if [[ -f "$cpu" ]]; then
            local max_freq=$(cat "${cpu%/scaling_max_freq}/cpuinfo_max_freq" 2>/dev/null || echo 0)
            local new_max=0
            
            case "$max_freq_pct" in
                "100%") new_max=$max_freq ;;
                "80%") new_max=$((max_freq * 80 / 100)) ;;
                "50%") new_max=$((max_freq * 50 / 100)) ;;
                "30%") new_max=$((max_freq * 30 / 100)) ;;
            esac
            
            echo "$new_max" > "$cpu" 2>/dev/null || true
        fi
    done
    
    log "CPU max frequency set to: $max_freq_pct"
}

# Get current battery status
get_battery_status() {
    local battery_path="/sys/class/power_supply/BAT0"
    
    if [[ ! -d "$battery_path" ]]; then
        battery_path="/sys/class/power_supply/BAT1"
    fi
    
    if [[ ! -d "$battery_path" ]]; then
        echo "No battery found"
        return 1
    fi
    
    local capacity=$(cat "$battery_path/capacity" 2>/dev/null || echo "0")
    local status=$(cat "$battery_path/status" 2>/dev/null || echo "Unknown")
    local voltage=$(cat "$battery_path/voltage_now" 2>/dev/null || echo "0")
    local current=$(cat "$battery_path/current_now" 2>/dev/null || echo "0")
    
    echo "Capacity: ${capacity}%"
    echo "Status: $status"
    echo "Voltage: $((voltage / 1000)) mV"
    echo "Current: $((current / 1000)) mA"
}

# Auto-switch profile based on battery
auto_profile() {
    local capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || \
                     cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo 100)
    local status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || \
                   cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo "Unknown")
    
    local current_profile=$(get_current_profile)
    local new_profile="$current_profile"
    
    # On AC power
    if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
        if [[ "$current_profile" != "performance" ]]; then
            new_profile="performance"
        fi
    # On battery
    else
        if [[ $capacity -le 10 ]]; then
            new_profile="ultra-powersave"
        elif [[ $capacity -le 20 ]]; then
            new_profile="powersave"
        elif [[ $capacity -le 50 ]]; then
            new_profile="balanced"
        else
            new_profile="performance"
        fi
    fi
    
    if [[ "$new_profile" != "$current_profile" ]]; then
        set_profile "$new_profile"
    fi
}

# Main function
main() {
    case "${1:-}" in
        set)
            set_profile "${2:-balanced}"
            ;;
        get)
            get_current_profile
            ;;
        auto)
            auto_profile
            ;;
        status)
            get_battery_status
            echo "Current profile: $(get_current_profile)"
            ;;
        *)
            echo "Usage: $0 {set|get|auto|status} [profile]"
            echo "Profiles: performance, balanced, powersave, ultra-powersave"
            exit 1
            ;;
    esac
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[PM-MANAGER]${NC} $1"; }
warn() { echo -e "${YELLOW}[PM-MANAGER]${NC} $1"; }
error() { echo -e "${RED}[PM-MANAGER]${NC} $1"; exit 1; }

# Load config
if [[ -f /etc/meridian/pm.conf ]]; then
    source /etc/meridian/pm.conf
fi

# Run main
main "$@"