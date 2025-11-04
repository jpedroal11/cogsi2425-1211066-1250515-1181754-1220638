#!/bin/bash

DB_HOST="192.168.56.11"
DB_PORT="9092"
MAX_ATTEMPTS=30
ATTEMPT=0

echo "=========================================="
echo "Starting Application"
echo "=========================================="
echo "Checking if H2 database is ready..."

# Wait for database to be ready
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  nc -z $DB_HOST $DB_PORT 2>/dev/null

  if [ $? -eq 0 ]; then
    echo "✓ H2 database is ready!"
    break
  fi

  ATTEMPT=$((ATTEMPT + 1))
  echo "Attempt $ATTEMPT/$MAX_ATTEMPTS: Waiting for database..."
  sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
  echo "✗ ERROR: H2 database failed to start within expected time"
  exit 1
fi

# Start the Spring Boot application
echo "Starting Spring Boot application..."
BASE_DIR=/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2
cd $BASE_DIR

# Use Gradle wrapper to run the application
./gradlew bootRun