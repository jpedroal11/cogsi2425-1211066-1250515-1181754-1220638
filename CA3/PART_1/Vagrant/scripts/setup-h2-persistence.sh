#!/usr/bin/env bash
set -e

# --- Directories ---
SYNC_DIR="/vagrant"
H2_DATA_DIR="$SYNC_DIR/h2-data"
APP_PROPERTIES="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2/app/src/main/resources/application.properties"
TEST_PROPERTIES="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2/app/src/integrationTest/resources/application-test.properties"

echo "=== Setting up persistent H2 database ==="

# Create data folder in synced directory
sudo mkdir -p "$H2_DATA_DIR"
sudo chmod 777 "$H2_DATA_DIR"

# Ensure the directory for main application.properties exists
APP_DIR=$(dirname "$APP_PROPERTIES")
mkdir -p "$APP_DIR"

# Create or overwrite application.properties for persistent H2
echo "Configuring application.properties..."
cat > "$APP_PROPERTIES" <<EOF
# ===============================
# H2 In-Memory Database Settings for Tests
# ===============================
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
EOF


echo "DONE"

echo "H2 database will store data in: $H2_DATA_DIR"
echo "H2 console available at /h2"
