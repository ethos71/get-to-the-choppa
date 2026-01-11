#!/bin/bash
# Test suite for concurrent AP-STA mode
# Tests that WiFi hotspot is working correctly

WIFI_INTERFACE="wlp0s20f3"
AP_INTERFACE="ap0"
EXPECTED_SSID="GetToTheSwitch"
UPSTREAM_SSID="GetToTheCHOPPAH"
AP_IP="10.42.0.1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

echo "=========================================="
echo "  WiFi Concurrent Mode Test Suite"
echo "=========================================="
echo ""

# Test 1: Check if connected to upstream network
test_upstream_connection() {
    echo -n "Test 1: Connected to $UPSTREAM_SSID... "
    if nmcli -t -f NAME,STATE connection show --active | grep -q "$UPSTREAM_SSID:activated"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: Not connected to $UPSTREAM_SSID"
        ((FAIL++))
        return 1
    fi
}

# Test 2: Check if AP interface exists
test_ap_interface_exists() {
    echo -n "Test 2: AP interface ($AP_INTERFACE) exists... "
    if iw dev | grep -q "$AP_INTERFACE"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: AP interface $AP_INTERFACE not found"
        ((FAIL++))
        return 1
    fi
}

# Test 3: Check if AP interface is in AP mode
test_ap_interface_mode() {
    echo -n "Test 3: AP interface in AP mode... "
    if iw dev "$AP_INTERFACE" info 2>/dev/null | grep -q "type AP"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: $AP_INTERFACE is not in AP mode"
        ((FAIL++))
        return 1
    fi
}

# Test 4: Check if AP SSID is correct
test_ap_ssid() {
    echo -n "Test 4: AP SSID is '$EXPECTED_SSID'... "
    ACTUAL_SSID=$(iw dev "$AP_INTERFACE" info 2>/dev/null | grep ssid | awk '{print $2}')
    if [ "$ACTUAL_SSID" = "$EXPECTED_SSID" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: Expected '$EXPECTED_SSID', got '$ACTUAL_SSID'"
        ((FAIL++))
        return 1
    fi
}

# Test 5: Check if both interfaces on same channel
test_same_channel() {
    echo -n "Test 5: Both interfaces on same channel... "
    MAIN_CHANNEL=$(iw dev "$WIFI_INTERFACE" info 2>/dev/null | grep channel | awk '{print $2}')
    AP_CHANNEL=$(iw dev "$AP_INTERFACE" info 2>/dev/null | grep channel | awk '{print $2}')
    if [ "$MAIN_CHANNEL" = "$AP_CHANNEL" ]; then
        echo -e "${GREEN}PASS${NC} (Channel $MAIN_CHANNEL)"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: Main on channel $MAIN_CHANNEL, AP on channel $AP_CHANNEL"
        ((FAIL++))
        return 1
    fi
}

# Test 6: Check if hostapd is running
test_hostapd_running() {
    echo -n "Test 6: hostapd process running... "
    if pgrep -f "hostapd.*concurrent" > /dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: hostapd not running"
        ((FAIL++))
        return 1
    fi
}

# Test 7: Check if dnsmasq is running
test_dnsmasq_running() {
    echo -n "Test 7: dnsmasq process running... "
    if pgrep -f "dnsmasq.*concurrent" > /dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: dnsmasq not running"
        ((FAIL++))
        return 1
    fi
}

# Test 8: Check if AP interface has correct IP
test_ap_ip() {
    echo -n "Test 8: AP interface IP is $AP_IP... "
    if ip addr show "$AP_INTERFACE" | grep -q "$AP_IP"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: AP interface doesn't have IP $AP_IP"
        ((FAIL++))
        return 1
    fi
}

# Test 9: Check if IP forwarding is enabled
test_ip_forwarding() {
    echo -n "Test 9: IP forwarding enabled... "
    if [ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: IP forwarding not enabled"
        ((FAIL++))
        return 1
    fi
}

# Test 10: Check if NAT iptables rules exist
test_nat_rules() {
    echo -n "Test 10: NAT iptables rules configured... "
    if sudo iptables -t nat -L POSTROUTING | grep -q "MASQUERADE"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: NAT rules not found"
        ((FAIL++))
        return 1
    fi
}

# Test 11: Check if can ping internet through main interface
test_internet_connectivity() {
    echo -n "Test 11: Internet connectivity (ping 8.8.8.8)... "
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${YELLOW}WARN${NC}"
        echo "  Warning: Cannot reach internet"
        return 0
    fi
}

# Test 12: Check if dnsmasq DHCP is configured correctly
test_dhcp_config() {
    echo -n "Test 12: DHCP range configured... "
    if sudo grep -q "dhcp-range=10.42.0" /etc/dnsmasq-concurrent.conf 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: DHCP configuration not found"
        ((FAIL++))
        return 1
    fi
}

# Run all tests
test_upstream_connection
test_ap_interface_exists
test_ap_interface_mode
test_ap_ssid
test_same_channel
test_hostapd_running
test_dnsmasq_running
test_ap_ip
test_ip_forwarding
test_nat_rules
test_internet_connectivity
test_dhcp_config

echo ""
echo "=========================================="
echo "  Test Results"
echo "=========================================="
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Concurrent mode is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Concurrent mode may not be working properly.${NC}"
    exit 1
fi
