#!/bin/bash
# Health check for H2 Database

set -e

echo "H2 Database Health Check"
echo "========================"

# Check if H2 service is running
if systemctl is-active --quiet h2; then
  echo "✓ H2 service is running"
else
  echo "✗ H2 service is NOT running"
  exit 1
fi

# Check if H2 TCP port is listening
if nc -z localhost 9092 2>/dev/null; then
  echo "✓ H2 TCP server is listening on port 9092"
else
  echo "✗ H2 TCP server is NOT accessible"
  exit 1
fi

# Check if H2 Web Console port is listening
if nc -z localhost 8082 2>/dev/null; then
  echo "✓ H2 Web Console is accessible on port 8082"
else
  echo "✗ H2 Web Console is NOT accessible"
  exit 1
fi

echo ""
echo "Database health check: PASSED ✓"

