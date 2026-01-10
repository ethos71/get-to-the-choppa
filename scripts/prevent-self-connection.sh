#!/bin/bash
# Prevent Laptop from Connecting to its Own Hotspots
# This creates a NetworkManager dispatcher script that blocks self-connections

set -e

echo "============================================"
echo "Installing Self-Connection Prevention"
echo "============================================"
echo ""

# Check for sudo
if [ "$EUID" -ne 0 ]; then 
    echo "This script needs sudo privileges."
    echo "Please run with: sudo ./prevent-self-connection.sh"
    exit 1
fi

# Create NetworkManager dispatcher script
cat > /etc/NetworkManager/dispatcher.d/99-no-self-connect << 'EOF'
#!/bin/bash
# Prevent laptop from connecting to its own hotspot SSIDs

INTERFACE=$1
ACTION=$2

# List of hotspot SSIDs we create (add new ones here)
HOTSPOT_SSIDS=(
    "GetToTheSwitch"
    "GetToTheOtherChoppa"
)

if [ "$ACTION" = "up" ]; then
    # When any interface comes up, check if we're trying to connect to our own hotspot
    CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
    
    for SSID in "${HOTSPOT_SSIDS[@]}"; do
        if [ "$CURRENT_SSID" = "$SSID" ]; then
            echo "WARNING: Detected connection to own hotspot '$SSID', disconnecting..."
            nmcli connection down "$CURRENT_SSID"
            logger "get-to-the-choppa: Prevented self-connection to $SSID"
        fi
    done
fi
EOF

chmod +x /etc/NetworkManager/dispatcher.d/99-no-self-connect

echo "✓ Created dispatcher script at /etc/NetworkManager/dispatcher.d/99-no-self-connect"
echo ""

# Ensure current hotspot has autoconnect disabled
if nmcli connection show Hotspot &>/dev/null; then
    nmcli connection modify Hotspot connection.autoconnect no
    echo "✓ Disabled autoconnect on existing Hotspot connection"
fi

# Create a list of known hotspot SSIDs that should never be connected to
mkdir -p /etc/choppa
cat > /etc/choppa/blocked-ssids.txt << 'EOF'
# List of SSIDs that this laptop hosts and should never connect to
# Add one SSID per line
GetToTheSwitch
GetToTheOtherChoppa
EOF

echo "✓ Created blocked SSID list at /etc/choppa/blocked-ssids.txt"
echo ""
echo "============================================"
echo "✓ Self-Connection Prevention Installed!"
echo "============================================"
echo ""
echo "Your laptop will now:"
echo "  • Never auto-connect to its own hotspots"
echo "  • Disconnect if it accidentally connects"
echo "  • Log any prevention attempts"
echo ""
echo "To add new hotspot SSIDs to the blocklist:"
echo "  1. Edit /etc/choppa/blocked-ssids.txt"
echo "  2. Edit /etc/NetworkManager/dispatcher.d/99-no-self-connect"
echo "  3. Add the SSID to the HOTSPOT_SSIDS array"
echo ""
