#!/bin/bash
# Check WiFi Hotspot Status
# Usage: ./check-status.sh

echo "============================================"
echo "WiFi Hotspot Status Check"
echo "============================================"
echo ""

if ! command -v nmcli &> /dev/null; then
    echo "ERROR: nmcli (NetworkManager) is not installed."
    exit 1
fi

# Check if hotspot is active
echo "Active Connections:"
nmcli -t -f NAME,TYPE,DEVICE connection show --active
echo ""

# Check hotspot connection specifically
HOTSPOT_STATUS=$(nmcli -t -f NAME,STATE connection show | grep "^Hotspot:" || echo "")

if [ -n "$HOTSPOT_STATUS" ]; then
    echo "Hotspot Details:"
    nmcli connection show Hotspot | grep -E "802-11-wireless\.(ssid|band|channel)|ipv4\.(method|address)" || true
    echo ""
    
    # Show connected devices if available
    echo "Checking for connected devices..."
    HOTSPOT_IFACE=$(nmcli -t -f DEVICE connection show --active | grep -v '^$' | tail -n 1)
    if [ -n "$HOTSPOT_IFACE" ]; then
        echo "Hotspot interface: $HOTSPOT_IFACE"
        if command -v arp &> /dev/null; then
            echo ""
            echo "Connected devices (ARP table):"
            arp -n | grep -v "incomplete" || echo "No devices detected yet"
        fi
    fi
else
    echo "⚠ No hotspot connection found."
    echo ""
    echo "To create a hotspot, run:"
    echo "  ./setup-hotspot.sh [SSID] [PASSWORD]"
fi

echo ""
echo "IP Forwarding Status:"
IP_FORWARD=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$IP_FORWARD" = "1" ]; then
    echo "✓ IP forwarding is enabled"
else
    echo "⚠ IP forwarding is disabled"
fi

echo ""
echo "Network Interfaces:"
ip addr show | grep -E "^[0-9]+:|inet " | head -n 20
