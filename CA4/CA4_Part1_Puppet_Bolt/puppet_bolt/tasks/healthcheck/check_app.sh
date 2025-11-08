#!/bin/bash
# Health check for Spring Boot application

set -e

echo "{"

# Check if service is running
if systemctl is-active --quiet springboot; then
  echo '  "service_status": "running",'
  SERVICE_OK=true
else
  echo '  "service_status": "not running",'
  SERVICE_OK=false
fi

# Check HTTP endpoint
if curl -f -s http://localhost:8080/employees > /dev/null 2>&1; then
  echo '  "http_status": "responding",'
  HTTP_OK=true
else
  echo '  "http_status": "not responding",'
  HTTP_OK=false
fi

# Check if port is listening
if ss -tln | grep -q ':8080'; then
  echo '  "port_status": "listening",'
  PORT_OK=true
else
  echo '  "port_status": "not listening",'
  PORT_OK=false
fi

# Overall status
if [ "$SERVICE_OK" = true ] && [ "$HTTP_OK" = true ] && [ "$PORT_OK" = true ]; then
  echo '  "status": "healthy",'
  echo '  "message": "Spring Boot application is running correctly"'
  EXIT_CODE=0
else
  echo '  "status": "unhealthy",'
  echo '  "message": "Spring Boot application has issues"'
  EXIT_CODE=1
fi

echo "}"

exit $EXIT_CODE

