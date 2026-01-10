# Technical Notes

## Architecture

### Network Flow
```
Internet → T-Mobile WiFi → Laptop WiFi/Ethernet → Laptop (routing) → Laptop WiFi (AP mode) → Nintendo Switch
```

### Components

#### 1. Upstream Connection (Internet)
- Connection to T-Mobile WiFi network
- Provides internet access to the system
- Interface: typically `wlan0` or ethernet `eth0`

#### 2. Routing/NAT Layer
- Linux kernel IP forwarding
- iptables NAT rules
- Translates addresses between networks

#### 3. Hotspot/AP (Access Point)
- Virtual WiFi interface or separate adapter
- DHCP server for client IP assignment
- DNS resolution for clients
- Interface: typically `wlan0` in AP mode or virtual interface

## Linux Tools

### NetworkManager
- High-level network management
- Automatic hotspot setup
- Handles DHCP, DNS, and NAT automatically
- Command: `nmcli`

### hostapd
- User space daemon for access point
- Low-level WiFi AP management
- Configuration file: `/etc/hostapd/hostapd.conf`

### dnsmasq
- Lightweight DHCP and DNS server
- Assigns IPs to connected clients
- Configuration file: `/etc/dnsmasq.conf`

### iptables
- Linux firewall and NAT
- Packet filtering and routing
- Essential for internet sharing

## Nintendo Switch Specifics

### WiFi Requirements
- **Frequency:** 2.4GHz (802.11b/g/n) or 5GHz (802.11a/n/ac)
- **Security:** WPA2-PSK (AES) recommended
- **Channels:** 1-11 for 2.4GHz (US region)

### Known Issues
- Some enterprise WiFi (WPA2-Enterprise) not supported
- Captive portals require browser (not available on Switch)
- Proxy servers not supported
- Some hotels/public WiFi require device registration

### Network Tests
```bash
# Test from Switch
Connection Test → Internet → NAT Type

# Desired results:
# - Connection successful
# - NAT Type: B or better
# - Download/Upload speeds adequate
```

## Performance Considerations

### Dual-Band Adapters
If your laptop has dual-band WiFi:
- Option 1: Connect to T-Mobile on 5GHz, host AP on 2.4GHz
- Option 2: Use Ethernet for upstream, WiFi for AP

### Single Adapter Limitations
- Cannot use same adapter for both upstream WiFi and AP simultaneously
- Solutions:
  - Use Ethernet for upstream
  - Use USB WiFi adapter for AP
  - Use virtual interface (not all adapters support)

## Security

### Recommended Settings
- Use WPA2-PSK (AES) encryption
- Strong password (12+ characters)
- Disable WPS if available
- Regular password rotation

### Network Isolation
The Switch will be on a separate subnet from your main network, providing some isolation.

## Debugging Commands

```bash
# Check IP forwarding
cat /proc/sys/net/ipv4/ip_forward

# View NAT rules
sudo iptables -t nat -L -n -v

# Monitor WiFi
sudo iw dev wlan0 station dump

# Check DHCP leases
cat /var/lib/misc/dnsmasq.leases

# View hotspot status
nmcli device show wlan0
```
