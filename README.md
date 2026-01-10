# Get to the Choppa! 🚁

A project to configure your laptop as a WiFi router/hotspot for Nintendo Switch connectivity.

## Problem
Your Nintendo Switch is having trouble connecting directly to your T-Mobile WiFi network.

## Solution
Use your laptop as an intermediary WiFi router that:
1. Connects to your T-Mobile WiFi network
2. Creates a new WiFi hotspot
3. Allows your Nintendo Switch to connect through the laptop

## Requirements
- Linux laptop with WiFi capability
- T-Mobile WiFi connection
- Nintendo Switch

## Documentation
See [docs/robots/](docs/robots/) for detailed guides and documentation:
- [Setup Guide](docs/robots/setup-guide.md) - Step-by-step setup instructions
- [Troubleshooting](docs/robots/troubleshooting.md) - Common issues and solutions
- [Technical Notes](docs/robots/technical-notes.md) - Architecture and implementation details

## Quick Start

### Option 1: Concurrent Mode (Recommended - stays connected to internet)
```bash
# Setup concurrent AP-STA mode (stay connected while hosting hotspot)
sudo ./scripts/setup-concurrent-mode.sh

# Stop concurrent mode
sudo ./scripts/stop-concurrent-mode.sh
```

### Option 2: NetworkManager Hotspot (disconnects from internet)
```bash
# Create a hotspot (will disconnect from GetToTheCHOPPAH)
nmcli device wifi hotspot ssid "Switch-Hotspot" password "your-password"

# Connect your Switch to "Switch-Hotspot"
```

### Stop Hotspot
```bash
nmcli connection down Hotspot
```

## Agent
This project includes a GitHub Copilot agent `@choppa` to help with setup and troubleshooting.

## License
MIT