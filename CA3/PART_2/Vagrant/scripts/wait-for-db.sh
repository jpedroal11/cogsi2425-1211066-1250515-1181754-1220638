#!/usr/bin/env bash
set -e

echo "=== Waiting for Database ==="
echo "Checking H2 at 192.168.56.10:9092..."

for i in {1..30}; do
    if nc -z 192.168.56.10 9092; then
        echo "SUCCESS: Database is ready!"
        
        PROJ_ROOT="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2"
        cd "$PROJ_ROOT"
        
        echo "Starting Spring Boot application..."
        nohup ./gradlew bootRun > /tmp/spring-boot.log 2>&1 &
        
        echo "Application starting..."
        echo "Access: http://localhost:18080"
        exit 0
    else
        echo "Attempt $i/30: Database not ready, waiting..."
        sleep 5
    fi
done

echo "ERROR: Database not available after 30 attempts"
exit 1