#!/bin/bash
# Setup WiFi Hotspot for Nintendo Switch
# Usage: ./setup-hotspot.sh [SSID] [PASSWORD]
#
# This script creates a WiFi hotspot using NetworkManager that shares
# the laptop's current internet connection with connected devices.

set -e

SSID="${1:-GetToTheSwitch}"
PASSWORD="${2:-12262012}"

echo "============================================"
echo "Get to the Choppa! WiFi Hotspot Setup"
echo "============================================"
echo ""
echo "SSID: $SSID"
echo "Password: $PASSWORD"
echo ""

# Check if NetworkManager is available
if ! command -v nmcli &> /dev/null; then
    echo "ERROR: nmcli (NetworkManager) is not installed."
    echo "Please install NetworkManager first."
    exit 1
fi

# Check if running with sufficient privileges
if ! nmcli general status &> /dev/null; then
    echo "ERROR: Unable to access NetworkManager."
    echo "You may need to run with sudo or check your permissions."
    exit 1
fi

# Get current active connection (this will be used for internet)
echo "Checking current internet connection..."
ACTIVE_CONNECTION=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep -v '^Hotspot' | head -n 1)

if [ -z "$ACTIVE_CONNECTION" ]; then
    echo "WARNING: No active internet connection detected."
    echo "The hotspot will be created but may not have internet access."
else
    echo "✓ Active connection found: $ACTIVE_CONNECTION"
fi

echo ""
echo "Creating WiFi hotspot..."

# Stop any existing hotspot
nmcli connection down Hotspot 2>/dev/null || true
nmcli connection delete Hotspot 2>/dev/null || true

# Create new hotspot
# Using 2.4GHz band (bg) and channel 6 for best Nintendo Switch compatibility
nmcli device wifi hotspot \
    ssid "$SSID" \
    password "$PASSWORD" \
    band bg \
    channel 6

if [ $? -eq 0 ]; then
    # Ensure the hotspot connection never auto-connects (prevent laptop from connecting to itself)
    nmcli connection modify Hotspot connection.autoconnect no
    
    echo "✓ Configured to prevent self-connection"
    echo ""
    echo "============================================"
    echo "✓ Hotspot created successfully!"
    echo "============================================"
    echo ""
    echo "Network Name (SSID): $SSID"
    echo "Password: $PASSWORD"
    echo "Band: 2.4GHz"
    echo "Channel: 6"
    echo ""
    echo "Nintendo Switch connection steps:"
    echo "1. Go to System Settings > Internet > Internet Settings"
    echo "2. Select '$SSID'"
    echo "3. Enter password: $PASSWORD"
    echo "4. Test connection"
    echo ""
    echo "To stop the hotspot, run:"
    echo "  nmcli connection down Hotspot"
    echo ""
else
    echo "ERROR: Failed to create hotspot."
    echo "Please check the troubleshooting guide in docs/robots/troubleshooting.md"
    exit 1
fi
