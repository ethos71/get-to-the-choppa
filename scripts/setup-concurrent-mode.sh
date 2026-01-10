#!/bin/bash

# Setup WiFi adapter in concurrent AP+STA mode
# This allows the laptop to stay connected to GetToTheCHOPPAH while also hosting a hotspot

set -e

WIFI_INTERFACE="wlp0s20f3"
AP_INTERFACE="ap0"
HOTSPOT_SSID="GetToTheSwitch"
HOTSPOT_PASSWORD="12262012"
UPSTREAM_SSID="GetToTheCHOPPAH"

echo "=== Setting up Concurrent AP-STA Mode ==="
echo "This will keep you connected to $UPSTREAM_SSID while hosting $HOTSPOT_SSID"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

# Get current channel from active connection
CURRENT_CHANNEL=$(iw dev $WIFI_INTERFACE info | grep channel | awk '{print $2}')
CURRENT_FREQ=$(iw dev $WIFI_INTERFACE info | grep channel | awk '{print $3}' | tr -d '()')

echo "Current connection:"
echo "  Interface: $WIFI_INTERFACE"
echo "  SSID: $UPSTREAM_SSID"
echo "  Channel: $CURRENT_CHANNEL"
echo "  Frequency: $CURRENT_FREQ"
echo ""

# Install required packages
echo "Checking required packages..."
PACKAGES="hostapd dnsmasq iptables"
for pkg in $PACKAGES; do
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        echo "Installing $pkg..."
        apt-get install -y $pkg
    fi
done

# Stop NetworkManager from managing the AP interface
echo "Configuring NetworkManager..."
cat > /etc/NetworkManager/conf.d/unmanaged-ap.conf <<EOF
[keyfile]
unmanaged-devices=interface-name:$AP_INTERFACE
EOF

# Create virtual AP interface
echo "Creating virtual AP interface $AP_INTERFACE..."
if iw dev | grep -q "$AP_INTERFACE"; then
    echo "  Interface $AP_INTERFACE already exists, removing..."
    iw dev $AP_INTERFACE del
fi
iw dev $WIFI_INTERFACE interface add $AP_INTERFACE type __ap

# Bring up the AP interface
ip link set $AP_INTERFACE up
ip addr add 10.42.0.1/24 dev $AP_INTERFACE

# Create hostapd configuration
echo "Creating hostapd configuration..."
cat > /etc/hostapd/hostapd-concurrent.conf <<EOF
interface=$AP_INTERFACE
driver=nl80211
ssid=$HOTSPOT_SSID
hw_mode=a
channel=$CURRENT_CHANNEL
wmm_enabled=1
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$HOTSPOT_PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

# Create dnsmasq configuration
echo "Creating dnsmasq configuration..."
cat > /etc/dnsmasq-concurrent.conf <<EOF
interface=$AP_INTERFACE
dhcp-range=10.42.0.10,10.42.0.50,255.255.255.0,24h
dhcp-option=3,10.42.0.1
dhcp-option=6,10.42.0.1
server=8.8.8.8
log-queries
log-dhcp
bind-interfaces
EOF

# Setup IP forwarding and NAT
echo "Setting up IP forwarding and NAT..."
echo 1 > /proc/sys/net/ipv4/ip_forward

# Clear existing iptables rules for this setup
iptables -t nat -D POSTROUTING -o $WIFI_INTERFACE -j MASQUERADE 2>/dev/null || true
iptables -D FORWARD -i $AP_INTERFACE -o $WIFI_INTERFACE -j ACCEPT 2>/dev/null || true
iptables -D FORWARD -i $WIFI_INTERFACE -o $AP_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true

# Add NAT rules
iptables -t nat -A POSTROUTING -o $WIFI_INTERFACE -j MASQUERADE
iptables -A FORWARD -i $AP_INTERFACE -o $WIFI_INTERFACE -j ACCEPT
iptables -A FORWARD -i $WIFI_INTERFACE -o $AP_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Stop any existing instances
echo "Stopping any existing services..."
pkill -f "hostapd.*concurrent" || true
pkill -f "dnsmasq.*concurrent" || true
sleep 2

# Start services
echo "Starting hostapd..."
hostapd -B /etc/hostapd/hostapd-concurrent.conf
sleep 3

echo "Starting dnsmasq..."
dnsmasq -C /etc/dnsmasq-concurrent.conf

echo ""
echo "=== Concurrent Mode Setup Complete ==="
echo ""
echo "Your laptop is now:"
echo "  ✓ Connected to: $UPSTREAM_SSID (channel $CURRENT_CHANNEL)"
echo "  ✓ Hosting hotspot: $HOTSPOT_SSID"
echo "  ✓ Password: $HOTSPOT_PASSWORD"
echo "  ✓ IP Range: 10.42.0.10-50"
echo ""
echo "To stop concurrent mode, run: sudo ./stop-concurrent-mode.sh"
echo ""
echo "Note: Both interfaces share channel $CURRENT_CHANNEL (5GHz)"
echo "      Performance may be reduced compared to dedicated hardware."
