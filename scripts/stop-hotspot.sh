#!/bin/bash
# Stop WiFi Hotspot
# Usage: ./stop-hotspot.sh

echo "Stopping WiFi hotspot..."

if ! command -v nmcli &> /dev/null; then
    echo "ERROR: nmcli (NetworkManager) is not installed."
    exit 1
fi

nmcli connection down Hotspot 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Hotspot stopped successfully."
else
    echo "No active hotspot found or already stopped."
fi
