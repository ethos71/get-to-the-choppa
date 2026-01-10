#!/bin/bash
# Scheduled Concurrent Mode Startup Script
# Runs at 6am - starts concurrent AP-STA mode after system resume

echo "[$(date)] Starting concurrent mode hotspot for scheduled resume"

# Wait a bit for system to fully wake up and network to stabilize
sleep 30

# Check if already connected to GetToTheCHOPPAH
if ! nmcli -t -f NAME,STATE connection show --active | grep -q "GetToTheCHOPPAH:activated"; then
    echo "Waiting for GetToTheCHOPPAH connection..."
    sleep 30
fi

# Start concurrent mode
/home/dominick/workspace/get-to-the-choppa/scripts/setup-concurrent-mode.sh

if [ $? -eq 0 ]; then
    echo "✓ Concurrent mode started successfully at $(date)"
    logger "get-to-the-choppa: Concurrent mode started after 6am resume"
else
    echo "ERROR: Failed to start concurrent mode"
    logger "get-to-the-choppa: ERROR - Failed to start concurrent mode after resume"
    exit 1
fi
