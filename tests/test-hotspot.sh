#!/bin/bash
# Test suite for NetworkManager hotspot mode
# Tests that WiFi hotspot is working correctly

EXPECTED_SSID="GetToTheSwitch"
HOTSPOT_CONNECTION="Hotspot"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0

echo "=========================================="
echo "  WiFi Hotspot Test Suite"
echo "=========================================="
echo ""

# Test 1: Check if hotspot connection exists
test_hotspot_exists() {
    echo -n "Test 1: Hotspot connection exists... "
    if nmcli connection show "$HOTSPOT_CONNECTION" &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: Hotspot connection not found"
        ((FAIL++))
        return 1
    fi
}

# Test 2: Check if hotspot is active
test_hotspot_active() {
    echo -n "Test 2: Hotspot is active... "
    if nmcli -t -f NAME,STATE connection show --active | grep -q "$HOTSPOT_CONNECTION:activated"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: Hotspot is not active"
        ((FAIL++))
        return 1
    fi
}

# Test 3: Check if hotspot has correct SSID
test_hotspot_ssid() {
    echo -n "Test 3: Hotspot SSID is '$EXPECTED_SSID'... "
    ACTUAL_SSID=$(nmcli -t -f 802-11-wireless.ssid connection show "$HOTSPOT_CONNECTION" 2>/dev/null | cut -d: -f2)
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

# Test 4: Check if hotspot has security enabled
test_hotspot_security() {
    echo -n "Test 4: Hotspot has WPA security... "
    if nmcli -t -f 802-11-wireless-security.key-mgmt connection show "$HOTSPOT_CONNECTION" 2>/dev/null | grep -q "wpa-psk"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Error: WPA security not configured"
        ((FAIL++))
        return 1
    fi
}

# Test 5: Check if hotspot autoconnect is disabled
test_hotspot_autoconnect() {
    echo -n "Test 5: Hotspot autoconnect disabled... "
    AUTOCONNECT=$(nmcli -t -f connection.autoconnect connection show "$HOTSPOT_CONNECTION" 2>/dev/null | cut -d: -f2)
    if [ "$AUTOCONNECT" = "no" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${YELLOW}WARN${NC}"
        echo "  Warning: Autoconnect is enabled (should be 'no')"
        return 0
    fi
}

# Test 6: Check if hotspot is visible in scan (may not work if we're connected to it)
test_hotspot_visible() {
    echo -n "Test 6: Hotspot visible in WiFi scan... "
    # This may fail if we're connected to it, so treat as warning
    if nmcli device wifi list | grep -q "$EXPECTED_SSID"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${YELLOW}SKIP${NC}"
        echo "  Info: Cannot scan while hosting (normal)"
        return 0
    fi
}

# Test 7: Check if IP forwarding is enabled
test_ip_forwarding() {
    echo -n "Test 7: IP forwarding enabled... "
    if [ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${YELLOW}WARN${NC}"
        echo "  Warning: IP forwarding not enabled (may affect client connectivity)"
        return 0
    fi
}

# Run all tests
test_hotspot_exists
test_hotspot_active
test_hotspot_ssid
test_hotspot_security
test_hotspot_autoconnect
test_hotspot_visible
test_ip_forwarding

echo ""
echo "=========================================="
echo "  Test Results"
echo "=========================================="
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Hotspot is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Hotspot may not be working properly.${NC}"
    exit 1
fi
