# Scheduled Hotspot Management

## Overview
The WiFi hotspot follows the same power schedule as your Plex server:
- **Midnight (00:00)**: Hotspot stops automatically before system suspend
- **6:00 AM**: Hotspot starts automatically after system resume

## Integration with Plex Schedule
This integrates seamlessly with your existing `/home/dominick/workspace/plex-me-hard` power schedule:
- System suspends at midnight (if lid closed)
- System wakes at 6am via RTC alarm
- Hotspot lifecycle matches system power state

## Installation

### Quick Install
```bash
cd /home/dominick/workspace/get-to-the-choppa/scripts
sudo ./install-schedule.sh
```

### What Gets Installed
1. **Scripts** (copied to `/usr/local/bin/`):
   - `scheduled-hotspot-stop.sh` - Stops hotspot at midnight
   - `scheduled-hotspot-start.sh` - Starts hotspot at 6am

2. **SystemD Services**:
   - `choppa-midnight-stop.timer` - Triggers at midnight
   - `choppa-midnight-stop.service` - Executes stop script
   - `choppa-6am-start.service` - Runs after suspend/resume

## Management

### Check Schedule Status
```bash
# View timer status
systemctl status choppa-midnight-stop.timer

# List all scheduled timers
systemctl list-timers | grep choppa

# Check next run time
systemctl list-timers --all
```

### View Logs
```bash
# Recent midnight stops
journalctl -u choppa-midnight-stop.service -n 20

# Recent 6am starts
journalctl -u choppa-6am-start.service -n 20

# System logs for hotspot
journalctl | grep "get-to-the-choppa"
```

### Enable/Disable Schedule
```bash
# Disable scheduled stops (keeps hotspot running 24/7)
sudo systemctl stop choppa-midnight-stop.timer
sudo systemctl disable choppa-midnight-stop.timer

# Disable scheduled starts
sudo systemctl disable choppa-6am-start.service

# Re-enable
sudo systemctl enable choppa-midnight-stop.timer
sudo systemctl start choppa-midnight-stop.timer
sudo systemctl enable choppa-6am-start.service
```

### Manual Control
Even with scheduling enabled, you can manually control the hotspot:
```bash
# Start hotspot now
./setup-hotspot.sh

# Stop hotspot now
./stop-hotspot.sh

# Check current status
./check-status.sh
```

## Behavior

### Midnight (00:00)
1. Timer triggers `choppa-midnight-stop.service`
2. Hotspot connection is stopped
3. Event logged to system journal
4. System proceeds with Plex suspend check
5. If lid closed, system suspends

### 6:00 AM Resume
1. System wakes via RTC alarm (Plex schedule)
2. After suspend.target completes
3. `choppa-6am-start.service` triggers
4. Waits 30 seconds for network stability
5. Starts hotspot with saved settings
6. Event logged to system journal

## Configuration

### Change Hotspot Settings
Edit `/usr/local/bin/scheduled-hotspot-start.sh`:
```bash
SSID="YourCustomName"
PASSWORD="YourCustomPassword"
```

Then restart services:
```bash
sudo systemctl daemon-reload
```

### Change Schedule Times
To modify when hotspot stops/starts:

1. Edit timer: `/etc/systemd/system/choppa-midnight-stop.timer`
2. Change `OnCalendar=` line
3. Reload: `sudo systemctl daemon-reload`
4. Restart timer: `sudo systemctl restart choppa-midnight-stop.timer`

## Troubleshooting

### Hotspot didn't stop at midnight
```bash
# Check if timer ran
journalctl -u choppa-midnight-stop.service -n 10

# Verify timer is enabled
systemctl is-enabled choppa-midnight-stop.timer
systemctl is-active choppa-midnight-stop.timer
```

### Hotspot didn't start at 6am
```bash
# Check resume logs
journalctl -u choppa-6am-start.service -n 10

# Check if system actually resumed
journalctl -b | grep -i suspend

# Verify service is enabled
systemctl is-enabled choppa-6am-start.service
```

### NetworkManager Issues
```bash
# Check NetworkManager status
systemctl status NetworkManager

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Try manual start
./setup-hotspot.sh
```

## Power Savings
- Hotspot only runs during active hours (6am - midnight)
- Saves WiFi power during suspend (midnight - 6am)
- Total active time: 18 hours/day
- Total suspend time: 6 hours/day

## Integration Points
- **Plex Midnight Suspend**: `plex-midnight-suspend.timer` (existing)
- **Plex RTC Wake**: Hardware RTC at 6am (existing)
- **Choppa Stop**: `choppa-midnight-stop.timer` (new)
- **Choppa Start**: `choppa-6am-start.service` (new)

## Uninstall
```bash
# Stop and disable services
sudo systemctl stop choppa-midnight-stop.timer
sudo systemctl disable choppa-midnight-stop.timer
sudo systemctl disable choppa-6am-start.service

# Remove service files
sudo rm /etc/systemd/system/choppa-midnight-stop.service
sudo rm /etc/systemd/system/choppa-midnight-stop.timer
sudo rm /etc/systemd/system/choppa-6am-start.service

# Remove scripts
sudo rm /usr/local/bin/scheduled-hotspot-stop.sh
sudo rm /usr/local/bin/scheduled-hotspot-start.sh

# Reload systemd
sudo systemctl daemon-reload
```

## Date Configured
2026-01-10
