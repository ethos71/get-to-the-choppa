# WiFi Router Setup Guide

## Overview
This guide walks you through setting up your Linux laptop as a WiFi router for your Nintendo Switch.

## Prerequisites
- Linux system (Ubuntu/Debian/Fedora/Arch)
- Working WiFi adapter
- Internet connection (T-Mobile WiFi)
- Root/sudo access

## Setup Methods

### Method 1: Using NetworkManager (Recommended)
NetworkManager provides the easiest way to create a hotspot on modern Linux systems.

#### Steps:
1. **Check WiFi adapter capabilities**
   ```bash
   iw list | grep -A 10 "Supported interface modes"
   ```
   Look for "AP" (Access Point) mode support.

2. **Create hotspot using nmcli**
   ```bash
   nmcli device wifi hotspot ssid "Switch-Hotspot" password "your-password"
   ```

3. **Configure connection sharing**
   NetworkManager automatically handles NAT and forwarding.

### Method 2: Using hostapd + dnsmasq
For more control or when NetworkManager isn't available.

#### Install required packages:
```bash
# Ubuntu/Debian
sudo apt-get install hostapd dnsmasq

# Fedora
sudo dnf install hostapd dnsmasq

# Arch
sudo pacman -S hostapd dnsmasq
```

## Nintendo Switch Connection
1. On your Switch, go to System Settings > Internet > Internet Settings
2. Select your new hotspot network
3. Enter the password
4. Test connection

## Troubleshooting
See [troubleshooting.md](troubleshooting.md) for common issues and solutions.
