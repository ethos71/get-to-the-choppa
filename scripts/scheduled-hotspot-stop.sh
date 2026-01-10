#!/bin/bash
# Scheduled Concurrent Mode Shutdown Script
# Runs at midnight - stops concurrent mode before system suspend

echo "[$(date)] Stopping concurrent mode for scheduled shutdown"

# Stop concurrent mode
/home/dominick/workspace/get-to-the-choppa/scripts/stop-concurrent-mode.sh

if [ $? -eq 0 ]; then
    echo "✓ Concurrent mode stopped successfully at $(date)"
else
    echo "No active concurrent mode found or already stopped"
fi

# Log the action
logger "get-to-the-choppa: Concurrent mode stopped for midnight suspend"
