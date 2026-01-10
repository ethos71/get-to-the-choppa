#!/bin/bash
# Add SSID to self-connection blocklist
# Usage: sudo ./add-blocked-ssid.sh "YourSSIDName"

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "This script needs sudo privileges."
    echo "Please run with: sudo ./add-blocked-ssid.sh \"SSID-NAME\""
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: sudo ./add-blocked-ssid.sh \"SSID-NAME\""
    echo ""
    echo "Current blocked SSIDs:"
    cat /etc/choppa/blocked-ssids.txt 2>/dev/null || echo "  (none yet)"
    exit 1
fi

NEW_SSID="$1"

echo "Adding '$NEW_SSID' to self-connection blocklist..."

# Add to blocked-ssids.txt
mkdir -p /etc/choppa
if ! grep -q "^${NEW_SSID}$" /etc/choppa/blocked-ssids.txt 2>/dev/null; then
    echo "$NEW_SSID" >> /etc/choppa/blocked-ssids.txt
    echo "✓ Added to /etc/choppa/blocked-ssids.txt"
else
    echo "  Already in blocked-ssids.txt"
fi

# Add to dispatcher script
if ! grep -q "\"${NEW_SSID}\"" /etc/NetworkManager/dispatcher.d/99-no-self-connect; then
    # Insert before the closing parenthesis
    sed -i "/^HOTSPOT_SSIDS=(/a\\    \"$NEW_SSID\"" /etc/NetworkManager/dispatcher.d/99-no-self-connect
    echo "✓ Added to dispatcher script"
else
    echo "  Already in dispatcher script"
fi

# Delete any existing client connection to this SSID
if nmcli connection show "$NEW_SSID" &>/dev/null; then
    nmcli connection delete "$NEW_SSID"
    echo "✓ Deleted existing client connection"
fi

if nmcli connection show "Auto $NEW_SSID" &>/dev/null; then
    nmcli connection delete "Auto $NEW_SSID"
    echo "✓ Deleted Auto connection"
fi

echo ""
echo "✓ '$NEW_SSID' is now blocked from self-connection"
echo ""
echo "Current blocked SSIDs:"
cat /etc/choppa/blocked-ssids.txt
