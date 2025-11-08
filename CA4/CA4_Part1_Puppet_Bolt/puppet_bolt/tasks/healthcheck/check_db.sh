#!/bin/bash
# Health check for H2 Database

set -e

echo "{"

# Check if service is running
if systemctl is-active --quiet h2; then
  echo '  "service_status": "running",'
  SERVICE_OK=true
else
  echo '  "service_status": "not running",'
  SERVICE_OK=false
fi

# Check if TCP port 9092 is listening
if ss -tln | grep -q ':9092'; then
  echo '  "tcp_port_status": "listening",'
  TCP_OK=true
else
  echo '  "tcp_port_status": "not listening",'
  TCP_OK=false
fi

# Check web console
if curl -f -s http://localhost:8082 > /dev/null 2>&1; then
  echo '  "web_console_status": "accessible",'
  WEB_OK=true
else
  echo '  "web_console_status": "not accessible",'
  WEB_OK=false
fi

# Overall status
if [ "$SERVICE_OK" = true ] && [ "$TCP_OK" = true ] && [ "$WEB_OK" = true ]; then
  echo '  "status": "healthy",'
  echo '  "message": "H2 Database is running correctly"'
  EXIT_CODE=0
else
  echo '  "status": "unhealthy",'
  echo '  "message": "H2 Database has issues"'
  EXIT_CODE=1
fi

echo "}"

exit $EXIT_CODE

