#!/bin/bash
# Health check for Spring Boot Application

set -e

echo "Spring Boot Application Health Check"
echo "====================================="

# Check if Spring Boot service is running
if systemctl is-active --quiet springboot; then
  echo "✓ Spring Boot service is running"
else
  echo "✗ Spring Boot service is NOT running"
  exit 1
fi

# Check if application is responding on port 8080
if nc -z localhost 8080 2>/dev/null; then
  echo "✓ Application is listening on port 8080"
else
  echo "✗ Application is NOT accessible"
  exit 1
fi

# Check if /employees endpoint returns 200
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/employees 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  echo "✓ /employees endpoint is responding (HTTP $HTTP_CODE)"
else
  echo "✗ /employees endpoint returned HTTP $HTTP_CODE"
  exit 1
fi

echo ""
echo "Application health check: PASSED ✓"

