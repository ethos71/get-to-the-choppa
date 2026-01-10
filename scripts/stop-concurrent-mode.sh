#!/bin/bash

# Stop concurrent AP-STA mode and clean up

set -e

WIFI_INTERFACE="wlp0s20f3"
AP_INTERFACE="ap0"

echo "=== Stopping Concurrent AP-STA Mode ==="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

# Stop services
echo "Stopping hostapd and dnsmasq..."
pkill -f "hostapd.*concurrent" || true
pkill -f "dnsmasq.*concurrent" || true

# Remove iptables rules
echo "Removing iptables rules..."
iptables -t nat -D POSTROUTING -o $WIFI_INTERFACE -j MASQUERADE 2>/dev/null || true
iptables -D FORWARD -i $AP_INTERFACE -o $WIFI_INTERFACE -j ACCEPT 2>/dev/null || true
iptables -D FORWARD -i $WIFI_INTERFACE -o $AP_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true

# Remove virtual interface
echo "Removing virtual AP interface..."
if iw dev | grep -q "$AP_INTERFACE"; then
    ip link set $AP_INTERFACE down 2>/dev/null || true
    iw dev $AP_INTERFACE del 2>/dev/null || true
fi

# Restart NetworkManager to restore normal operation
echo "Restarting NetworkManager..."
systemctl restart NetworkManager

echo ""
echo "=== Concurrent Mode Stopped ==="
echo "Your WiFi connection to GetToTheCHOPPAH should still be active."
