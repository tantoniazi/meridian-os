#!/bin/bash
# Meridian OS - Hardware Kill Switch Handler
# Handles hardware kill switch events for various devices

set -euo pipefail

SWITCH_TYPE="${1:-}"
SWITCH_STATE="${2:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[KILLSWITCH]${NC} $1"; }
warn() { echo -e "${YELLOW}[KILLSWITCH]${NC} $1"; }
error() { echo -e "${RED}[KILLSWITCH]${NC} $1"; }

# Validate arguments
if [[ -z "$SWITCH_TYPE" || -z "$SWITCH_STATE" ]]; then
    error "Usage: $0 <switch_type> <state>"
    error "Switch types: modem, wifi, bluetooth, camera, microphone"
    error "States: 0 (off/kill), 1 (on/enable)"
fi

# Validate state
if [[ "$SWITCH_STATE" != "0" && "$SWITCH_STATE" != "1" ]]; then
    error "Invalid state: $SWITCH_STATE (must be 0 or 1)"
fi

log "Kill switch event: $SWITCH_TYPE = $SWITCH_STATE"

# Handle switch event
handle_switch() {
    local type="$1"
    local state="$2"
    local action=""
    
    if [[ "$state" == "0" ]]; then
        action="disable"
        log "Kill switch ENGAGED for $type - disabling hardware"
    else
        action="enable"
        log "Kill switch DISENGAGED for $type - enabling hardware"
    fi
    
    case "$type" in
        modem)
            handle_modem "$action"
            ;;
        wifi)
            handle_wifi "$action"
            ;;
        bluetooth)
            handle_bluetooth "$action"
            ;;
        camera)
            handle_camera "$action"
            ;;
        microphone|mic)
            handle_microphone "$action"
            ;;
        *)
            warn "Unknown switch type: $type"
            ;;
    esac
}

# Modem handler
handle_modem() {
    local action="$1"
    
    case "$action" in
        disable)
            log "Disabling modem..."
            # Disable modem via ModemManager
            mmcli -m any --disable 2>/dev/null || true
            
            # Power off modem via GPIO if available
            if [[ -f /sys/class/gpio/modem_power/value ]]; then
                echo 0 > /sys/class/gpio/modem_power/value 2>/dev/null || true
            fi
            
            # Kill switch engaged notification
            notify-send "Hardware Kill Switch" "Modem disabled" --icon=network-cellular-disconnected --urgency=critical
            ;;
        enable)
            log "Enabling modem..."
            # Power on modem via GPIO
            if [[ -f /sys/class/gpio/modem_power/value ]]; then
                echo 1 > /sys/class/gpio/modem_power/value 2>/dev/null || true
            fi
            
            # Enable modem via ModemManager
            mmcli -m any --enable 2>/dev/null || true
            
            # Kill switch disengaged notification
            notify-send "Hardware Kill Switch" "Modem enabled" --icon=network-cellular-connected
            ;;
    esac
}

# WiFi handler
handle_wifi() {
    local action="$1"
    
    case "$action" in
        disable)
            log "Disabling WiFi..."
            rfkill block wifi 2>/dev/null || true
            
            # Stop wpa_supplicant
            systemctl stop wpa_supplicant 2>/dev/null || true
            
            # Power down WiFi hardware
            if [[ -f /sys/class/rfkill/rfkill*/type ]]; then
                for rfkill in /sys/class/rfkill/rfkill*; do
                    if [[ $(cat "$rfkill/type" 2>/dev/null) == "wlan" ]]; then
                        echo 1 > "$rfkill/state" 2>/dev/null || true
                    fi
                done
            fi
            
            notify-send "Hardware Kill Switch" "WiFi disabled" --icon=network-wireless-disconnected --urgency=critical
            ;;
        enable)
            log "Enabling WiFi..."
            rfkill unblock wifi 2>/dev/null || true
            
            # Power up WiFi hardware
            if [[ -f /sys/class/rfkill/rfkill*/type ]]; then
                for rfkill in /sys/class/rfkill/rfkill*; do
                    if [[ $(cat "$rfkill/type" 2>/dev/null) == "wlan" ]]; then
                        echo 0 > "$rfkill/state" 2>/dev/null || true
                    fi
                done
            fi
            
            # Start wpa_supplicant
            systemctl start wpa_supplicant 2>/dev/null || true
            
            notify-send "Hardware Kill Switch" "WiFi enabled" --icon=network-wireless-connected
            ;;
    esac
}

# Bluetooth handler
handle_bluetooth() {
    local action="$1"
    
    case "$action" in
        disable)
            log "Disabling Bluetooth..."
            rfkill block bluetooth 2>/dev/null || true
            
            # Stop Bluetooth service
            systemctl stop bluetooth 2>/dev/null || true
            
            notify-send "Hardware Kill Switch" "Bluetooth disabled" --icon=bluetooth-disabled --urgency=critical
            ;;
        enable)
            log "Enabling Bluetooth..."
            rfkill unblock bluetooth 2>/dev/null || true
            
            # Start Bluetooth service
            systemctl start bluetooth 2>/dev/null || true
            
            notify-send "Hardware Kill Switch" "Bluetooth enabled" --icon=bluetooth-active
            ;;
    esac
}

# Camera handler
handle_camera() {
    local action="$1"
    
    case "$action" in
        disable)
            log "Disabling camera..."
            # Block camera access via udev
            echo 1 > /sys/class/video4linux/video*/device/authorized 2>/dev/null || true
            
            # Kill any camera processes
            pkill -f "camera\|cheese\|guvcview" 2>/dev/null || true
            
            notify-send "Hardware Kill Switch" "Camera disabled" --icon=camera-video-disabled --urgency=critical
            ;;
        enable)
            log "Enabling camera..."
            # Allow camera access
            echo 1 > /sys/class/video4linux/video*/device/authorized 2>/dev/null || true
            
            notify-send "Hardware Kill Switch" "Camera enabled" --icon=camera-video
            ;;
    esac
}

# Microphone handler
handle_microphone() {
    local action="$1"
    
    case "$action" in
        disable)
            log "Disabling microphone..."
            # Mute microphone via ALSA
            amixer -c 0 set Capture nocap 2>/dev/null || true
            amixer -c 0 set "Mic Boost" 0% 2>/dev/null || true
            
            # Block microphone access via PulseWire
            pactl set-source-mute @DEFAULT_SOURCE@ 1 2>/dev/null || true
            
            notify-send "Hardware Kill Switch" "Microphone disabled" --icon=audio-input-microphone-muted --urgency=critical
            ;;
        enable)
            log "Enabling microphone..."
            # Unmute microphone
            amixer -c 0 set Capture cap 2>/dev/null || true
            amixer -c 0 set "Mic Boost" 50% 2>/dev/null || true
            
            # Unmute via PulseWire
            pactl set-source-mute @DEFAULT_SOURCE@ 0 2>/dev/null || true
            
            notify-send "Hardware Kill Switch" "Microphone enabled" --icon=audio-input-microphone
            ;;
    esac
}

# Main function
main() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: $0 <switch_type> <state>"
        echo "Switch types: modem, wifi, bluetooth, camera, microphone"
        echo "States: 0 (off/kill), 1 (on/enable)"
        exit 1
    fi
    
    handle_switch "$1" "$2"
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[KILLSWITCH]${NC} $1"; }
warn() { echo -e "${YELLOW}[KILLSWITCH]${NC} $1"; }
error() { echo -e "${RED}[KILLSWITCH]${NC} $1"; exit 1; }

# Run main
main "$@"