# Troubleshooting Guide

## Common Issues

### WiFi Adapter Not Supporting AP Mode
**Problem:** Your WiFi adapter doesn't support Access Point mode.

**Solution:**
- Check with `iw list | grep -A 10 "Supported interface modes"`
- Consider using a USB WiFi adapter that supports AP mode
- Use Ethernet for upstream connection if available

### Switch Can't See the Hotspot
**Problem:** Nintendo Switch doesn't detect the created hotspot.

**Possible causes:**
1. Wrong WiFi channel (Switch supports 2.4GHz channels 1-11)
2. Hotspot not started properly
3. WiFi adapter in use by another connection

**Solutions:**
```bash
# Force 2.4GHz and specific channel
nmcli device wifi hotspot ssid "Switch-Hotspot" band bg channel 6 password "your-password"
```

### Connection Keeps Dropping
**Problem:** Switch connects but loses connection frequently.

**Solutions:**
1. Reduce distance between laptop and Switch
2. Change WiFi channel to avoid interference
3. Disable power saving on WiFi adapter:
   ```bash
   sudo iw dev wlan0 set power_save off
   ```

### No Internet Access on Switch
**Problem:** Switch connects to hotspot but can't access internet.

**Check:**
1. Laptop has internet connection
2. IP forwarding is enabled:
   ```bash
   sudo sysctl net.ipv4.ip_forward=1
   ```
3. NAT rules are configured properly:
   ```bash
   sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
   ```

### T-Mobile WiFi Compatibility
**Problem:** Specific issues with T-Mobile WiFi networks.

**Notes:**
- Some T-Mobile routers use client isolation
- Try connecting laptop via Ethernet if available
- Check if MAC address filtering is enabled on T-Mobile router

## Nintendo Switch Network Requirements
- 2.4GHz WiFi (not 5GHz)
- WPA2-PSK security (most common)
- DHCP enabled
- DNS servers accessible
- Ports: 1-65535 UDP/TCP (for full functionality)

## Getting Help
If issues persist, gather this information:
```bash
# System info
uname -a
lsb_release -a

# Network devices
ip link show
iw dev

# Active connections
nmcli connection show --active
```
