# @choppa - WiFi Router Agent

## Purpose
Configure and manage laptop as WiFi router/hotspot for Nintendo Switch connectivity.

## Context
Nintendo Switch having connection issues with T-Mobile WiFi. This agent helps configure the laptop to act as an intermediary router.

## Key Tasks
- Set up WiFi hotspot on laptop
- Configure network sharing/routing
- Optimize settings for Nintendo Switch compatibility
- Troubleshoot connection issues
- Monitor connection status
- Create automation scripts

## Project Structure
- **scripts/**: All automation and utility scripts go here
- **docs/robots/**: Documentation and guides
- **tests/**: Test suites for validation

## Script Guidelines
- All new scripts must be placed in `scripts/` directory
- Use clear, descriptive names (e.g., `setup-hotspot.sh`, `check-connection.sh`)
- Include usage comments at the top of each script
- Make scripts executable with `chmod +x`
- Prefer bash for portability

## Testing Requirements
**CRITICAL**: Before reporting any hotspot fix or feature as complete, you MUST:
1. Run the test suite: `./tests/run-all-tests.sh`
2. Report test results in your response
3. Only mark as "done" or "fixed" if all tests pass

Test suites validate:
- Concurrent AP-STA mode functionality
- NetworkManager hotspot mode functionality
- Interface configuration
- Network connectivity
- DHCP/DNS services
- NAT/routing rules

## Target Platform
- Host: Laptop (Linux)
- Client: Nintendo Switch
- Upstream: T-Mobile WiFi
