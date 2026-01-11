#!/bin/bash
# Run all test suites

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "  Get to the Choppa - Test Suite"
echo "==========================================${NC}"
echo ""

# Detect which mode is active
CONCURRENT_MODE=false
HOTSPOT_MODE=false

if iw dev | grep -q "ap0"; then
    CONCURRENT_MODE=true
fi

if nmcli -t -f NAME,STATE connection show --active | grep -q "Hotspot:activated"; then
    HOTSPOT_MODE=true
fi

# Run appropriate tests
if [ "$CONCURRENT_MODE" = true ]; then
    echo "Detected: Concurrent AP-STA mode active"
    echo ""
    "$SCRIPT_DIR/test-concurrent-mode.sh"
    TEST_EXIT=$?
elif [ "$HOTSPOT_MODE" = true ]; then
    echo "Detected: NetworkManager Hotspot mode active"
    echo ""
    "$SCRIPT_DIR/test-hotspot.sh"
    TEST_EXIT=$?
else
    echo -e "${RED}No active hotspot detected.${NC}"
    echo ""
    echo "Please start either:"
    echo "  - Concurrent mode: sudo ./scripts/setup-concurrent-mode.sh"
    echo "  - Hotspot mode: ./scripts/setup-hotspot.sh"
    exit 1
fi

echo ""
if [ $TEST_EXIT -eq 0 ]; then
    echo -e "${GREEN}=========================================="
    echo "  ✓ ALL TESTS PASSED"
    echo "==========================================${NC}"
    exit 0
else
    echo -e "${RED}=========================================="
    echo "  ✗ SOME TESTS FAILED"
    echo "==========================================${NC}"
    exit 1
fi
