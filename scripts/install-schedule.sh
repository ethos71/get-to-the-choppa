#!/bin/bash
# Install scheduled hotspot startup/shutdown to work with plex power schedule
# This integrates with the existing midnight suspend / 6am resume schedule

set -e

echo "============================================"
echo "Installing Get to the Choppa Schedule"
echo "============================================"
echo ""
echo "This will configure the hotspot to:"
echo "  - Stop at midnight (before system suspend)"
echo "  - Start at 6am (after system resume)"
echo ""
echo "This integrates with your existing Plex server schedule."
echo ""

# Check for sudo
if [ "$EUID" -ne 0 ]; then 
    echo "This script needs sudo privileges to install systemd services."
    echo "Please run with: sudo ./install-schedule.sh"
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "Installing scripts..."

# Copy scripts to /usr/local/bin
cp "$SCRIPT_DIR/scheduled-hotspot-stop.sh" /usr/local/bin/
cp "$SCRIPT_DIR/scheduled-hotspot-start.sh" /usr/local/bin/
chmod +x /usr/local/bin/scheduled-hotspot-stop.sh
chmod +x /usr/local/bin/scheduled-hotspot-start.sh

echo "✓ Scripts installed to /usr/local/bin/"

# Create systemd service for midnight stop
cat > /etc/systemd/system/choppa-midnight-stop.service << 'EOF'
[Unit]
Description=Stop WiFi Hotspot at Midnight
After=network.target
Before=plex-midnight-suspend.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/scheduled-hotspot-stop.sh
User=dominick

[Install]
WantedBy=multi-user.target
EOF

echo "✓ Created choppa-midnight-stop.service"

# Create systemd timer for midnight stop
cat > /etc/systemd/system/choppa-midnight-stop.timer << 'EOF'
[Unit]
Description=Stop WiFi Hotspot at Midnight Timer

[Timer]
OnCalendar=*-*-* 00:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "✓ Created choppa-midnight-stop.timer"

# Create systemd service for 6am start
cat > /etc/systemd/system/choppa-6am-start.service << 'EOF'
[Unit]
Description=Start WiFi Hotspot at 6am
After=suspend.target network.target NetworkManager.service
Wants=network.target NetworkManager.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/scheduled-hotspot-start.sh
User=dominick
Restart=on-failure
RestartSec=60

[Install]
WantedBy=suspend.target
EOF

echo "✓ Created choppa-6am-start.service"

# Reload systemd
systemctl daemon-reload

# Enable and start services
systemctl enable choppa-midnight-stop.timer
systemctl start choppa-midnight-stop.timer

systemctl enable choppa-6am-start.service

echo ""
echo "============================================"
echo "✓ Installation Complete!"
echo "============================================"
echo ""
echo "Schedule configured:"
echo "  • Midnight (00:00): Hotspot stops automatically"
echo "  • 6:00 AM: Hotspot starts after system resume"
echo ""
echo "Verify installation:"
echo "  systemctl status choppa-midnight-stop.timer"
echo "  systemctl list-timers | grep choppa"
echo ""
echo "View logs:"
echo "  journalctl -u choppa-midnight-stop.service -n 20"
echo "  journalctl -u choppa-6am-start.service -n 20"
echo ""
echo "Manual control:"
echo "  Start hotspot: $SCRIPT_DIR/setup-hotspot.sh"
echo "  Stop hotspot:  $SCRIPT_DIR/stop-hotspot.sh"
echo ""
