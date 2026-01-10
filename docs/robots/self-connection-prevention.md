# Self-Connection Prevention

## Problem
When creating WiFi hotspots, the laptop might try to connect to its own hosted network, causing conflicts and connection issues.

## Solution
Installed automatic prevention mechanisms that:
1. Disable autoconnect on all hotspot connections
2. Monitor network connections via NetworkManager dispatcher
3. Automatically disconnect if self-connection is detected
4. Maintain a blocklist of hotspot SSIDs

## Implementation

### NetworkManager Dispatcher Script
Location: `/etc/NetworkManager/dispatcher.d/99-no-self-connect`

Monitors all network interface changes and:
- Detects when laptop connects to its own hotspot SSID
- Automatically disconnects if self-connection occurs
- Logs the prevention to system journal

### Blocked SSID List
Location: `/etc/choppa/blocked-ssids.txt`

Maintains list of hotspot SSIDs that should never be connected to:
- GetToTheSwitch
- GetToTheOtherChoppa
- (Add more as needed)

### Connection Settings
All hotspot connections automatically configured with:
```
connection.autoconnect: no
```

## Adding New Hotspot SSIDs

When creating a new hotspot with a different name, add it to the blocklist:

### Method 1: Edit the dispatcher script
```bash
sudo nano /etc/NetworkManager/dispatcher.d/99-no-self-connect
```

Add the new SSID to the array:
```bash
HOTSPOT_SSIDS=(
    "GetToTheSwitch"
    "GetToTheOtherChoppa"
    "YourNewSSID"  # Add here
)
```

### Method 2: Edit the blocked list
```bash
sudo nano /etc/choppa/blocked-ssids.txt
```

Add one SSID per line:
```
GetToTheSwitch
GetToTheOtherChoppa
YourNewSSID
```

## Verification

### Check Current Settings
```bash
# Verify autoconnect is disabled
nmcli connection show Hotspot | grep autoconnect

# View dispatcher script
cat /etc/NetworkManager/dispatcher.d/99-no-self-connect

# View blocked SSIDs
cat /etc/choppa/blocked-ssids.txt
```

### Monitor for Prevention Events
```bash
# Check system logs for prevention attempts
journalctl | grep "get-to-the-choppa" | grep "self-connection"

# Watch in real-time
journalctl -f | grep "get-to-the-choppa"
```

## How It Works

### Prevention Flow
1. **Hotspot Created** → Autoconnect disabled immediately
2. **Network Interface Up** → Dispatcher script checks SSID
3. **Self-Connection Detected** → Automatic disconnection
4. **Event Logged** → Recorded in system journal

### Example Scenario
```
1. Laptop creates hotspot "GetToTheSwitch"
2. WiFi scans and sees "GetToTheSwitch" 
3. System attempts auto-connect (prevented by autoconnect=no)
4. If somehow connected, dispatcher detects and disconnects
5. Event logged: "Prevented self-connection to GetToTheSwitch"
```

## Troubleshooting

### Laptop Still Connecting to Own Hotspot
```bash
# Manually disconnect
nmcli connection down "GetToTheSwitch"

# Verify dispatcher is executable
ls -la /etc/NetworkManager/dispatcher.d/99-no-self-connect

# Test dispatcher manually
sudo /etc/NetworkManager/dispatcher.d/99-no-self-connect wlp0s20f3 up
```

### Dispatcher Not Running
```bash
# Check NetworkManager service
systemctl status NetworkManager

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Check dispatcher logs
journalctl -u NetworkManager -n 50
```

## Installation Script
Run anytime to reinstall or update:
```bash
cd /home/dominick/workspace/get-to-the-choppa/scripts
sudo ./prevent-self-connection.sh
```

## Integration with Hotspot Scripts
All hotspot creation scripts automatically:
- Set `autoconnect no` on creation
- Work with dispatcher script
- Support multiple SSID names

Scripts affected:
- `setup-hotspot.sh`
- `scheduled-hotspot-start.sh`

## Enhanced Self-Connection Prevention

**Updated:** 2026-01-10 22:10

### Additional Protections Added

The dispatcher script now includes:

1. **Active Deletion** - Automatically deletes any client connections to hotspot SSIDs
2. **Multiple Event Triggers** - Monitors both "up" and "connectivity-change" events
3. **Proactive Scanning** - Runs checks on every dispatcher event
4. **Connection Name Matching** - Catches both direct and "Auto" connections

### New Script: add-blocked-ssid.sh

Easily add new hotspot names to the blocklist:
```bash
cd /home/dominick/workspace/get-to-the-choppa/scripts
sudo ./add-blocked-ssid.sh "NewHotspotName"
```

This automatically:
- Adds to `/etc/choppa/blocked-ssids.txt`
- Updates the dispatcher script
- Deletes any existing client connections

### Current Protection Status
2026-01-10
