#!/bin/bash
# List Current Hotspots
# Shows all active and configured hotspots on this laptop

echo "============================================"
echo "Get to the Choppa! - Hotspot List"
echo "============================================"
echo ""

# Check if NetworkManager is available
if ! command -v nmcli &> /dev/null; then
    echo "ERROR: nmcli (NetworkManager) is not installed."
    exit 1
fi

# Show currently active hotspot
echo "📡 ACTIVE HOTSPOT:"
echo "────────────────────────────────────────────"
ACTIVE_HOTSPOT=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep "wifi" | grep -v "^GetToTheCHOPPAH" | head -1)

if [ -n "$ACTIVE_HOTSPOT" ]; then
    CONN_NAME=$(echo "$ACTIVE_HOTSPOT" | cut -d':' -f1)
    DEVICE=$(echo "$ACTIVE_HOTSPOT" | cut -d':' -f3)
    
    # Get hotspot details
    SSID=$(nmcli -t -f 802-11-wireless.ssid connection show "$CONN_NAME" | cut -d':' -f2)
    MODE=$(nmcli -t -f 802-11-wireless.mode connection show "$CONN_NAME" | cut -d':' -f2)
    BAND=$(nmcli -t -f 802-11-wireless.band connection show "$CONN_NAME" | cut -d':' -f2)
    CHANNEL=$(nmcli -t -f 802-11-wireless.channel connection show "$CONN_NAME" | cut -d':' -f2)
    
    if [ "$MODE" = "ap" ]; then
        echo "✓ RUNNING"
        echo ""
        echo "  Name (SSID): $SSID"
        echo "  Connection:  $CONN_NAME"
        echo "  Device:      $DEVICE"
        echo "  Band:        $BAND"
        echo "  Channel:     $CHANNEL"
        echo "  Mode:        Access Point (AP)"
        echo ""
        
        # Show password with QR code
        echo "  Credentials:"
        nmcli dev wifi show-password 2>/dev/null | sed 's/^/  /'
    else
        echo "⚠ No active hotspot (device in client mode)"
    fi
else
    echo "⚠ No active hotspot found"
    echo ""
    echo "  To start a hotspot, run:"
    echo "  ./setup-hotspot.sh"
fi

echo ""
echo "────────────────────────────────────────────"
echo ""

# Show all configured hotspot connections
echo "💾 CONFIGURED HOTSPOTS:"
echo "────────────────────────────────────────────"

HOTSPOT_CONNS=$(nmcli -t -f NAME,TYPE connection show | grep ":wifi$" | cut -d':' -f1)

if [ -z "$HOTSPOT_CONNS" ]; then
    echo "No configured hotspot connections found."
else
    while IFS= read -r CONN; do
        MODE=$(nmcli -t -f 802-11-wireless.mode connection show "$CONN" 2>/dev/null | cut -d':' -f2)
        AUTOCONNECT=$(nmcli -t -f connection.autoconnect connection show "$CONN" 2>/dev/null | cut -d':' -f2)
        SSID=$(nmcli -t -f 802-11-wireless.ssid connection show "$CONN" 2>/dev/null | cut -d':' -f2)
        
        # Only show AP mode connections
        if [ "$MODE" = "ap" ]; then
            ACTIVE_MARKER=""
            if echo "$ACTIVE_HOTSPOT" | grep -q "^$CONN:"; then
                ACTIVE_MARKER=" [ACTIVE]"
            fi
            
            echo ""
            echo "  Connection: $CONN$ACTIVE_MARKER"
            echo "  SSID:       $SSID"
            echo "  Autoconnect: $AUTOCONNECT"
        fi
    done <<< "$HOTSPOT_CONNS"
fi

echo ""
echo "────────────────────────────────────────────"
echo ""

# Show blocked SSIDs
echo "🚫 BLOCKED SSIDs (Self-Connection Prevention):"
echo "────────────────────────────────────────────"
if [ -f /etc/choppa/blocked-ssids.txt ]; then
    grep -v "^#" /etc/choppa/blocked-ssids.txt | grep -v "^$" | while read -r SSID; do
        echo "  • $SSID"
    done
else
    echo "  No blocked SSIDs configured"
fi

echo ""
echo "────────────────────────────────────────────"
echo ""

# Show upstream internet connection
echo "🌐 UPSTREAM INTERNET:"
echo "────────────────────────────────────────────"
UPSTREAM=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep "802-11-wireless" | grep -v "ap" | head -1)

if [ -n "$UPSTREAM" ]; then
    UP_NAME=$(echo "$UPSTREAM" | cut -d':' -f1)
    UP_DEVICE=$(echo "$UPSTREAM" | cut -d':' -f3)
    UP_SSID=$(nmcli -t -f 802-11-wireless.ssid connection show "$UP_NAME" 2>/dev/null | cut -d':' -f2)
    
    echo "  Connected to: $UP_SSID"
    echo "  Connection:   $UP_NAME"
    echo "  Device:       $UP_DEVICE"
else
    echo "  ⚠ No active WiFi connection"
fi

echo ""
echo "────────────────────────────────────────────"
echo ""

# Show schedule status
echo "⏰ SCHEDULE STATUS:"
echo "────────────────────────────────────────────"
if systemctl is-enabled choppa-midnight-stop.timer &>/dev/null; then
    NEXT_STOP=$(systemctl list-timers choppa-midnight-stop.timer 2>/dev/null | grep choppa | awk '{print $1, $2, $3}')
    echo "  ✓ Scheduled shutdown: Enabled"
    if [ -n "$NEXT_STOP" ]; then
        echo "    Next stop: $NEXT_STOP"
    fi
else
    echo "  ⚠ Scheduled shutdown: Disabled"
fi

if systemctl is-enabled choppa-6am-start.service &>/dev/null; then
    echo "  ✓ Scheduled startup: Enabled (on resume at 6am)"
else
    echo "  ⚠ Scheduled startup: Disabled"
fi

echo ""
echo "============================================"
echo "Commands:"
echo "  Start hotspot:  ./setup-hotspot.sh"
echo "  Stop hotspot:   ./stop-hotspot.sh"
echo "  Check status:   ./check-status.sh"
echo "============================================"
