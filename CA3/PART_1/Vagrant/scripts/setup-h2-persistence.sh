#!/usr/bin/env bash
set -e

# --- Directories ---
SYNC_DIR="/vagrant"
H2_DATA_DIR="$SYNC_DIR/h2-data"
APP_PROPERTIES="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2/app/src/main/resources/application.properties"
TEST_PROPERTIES="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2/app/src/integrationTest/resources/application-test.properties"
PROJ_ROOT="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2"

echo "=== Setting up persistent H2 database ==="
# Create data folder in synced directory
sudo mkdir -p "$H2_DATA_DIR"
sudo chmod 777 "$H2_DATA_DIR"

# Ensure the directory for main application.properties exists
APP_DIR=$(dirname "$APP_PROPERTIES")
mkdir -p "$APP_DIR"

# --- Configure persistent H2 database ---
echo "Configuring application.properties for persistent H2..."

cat > "$APP_PROPERTIES" <<EOF
# =========================================
# H2 Persistent Database Configuration
# =========================================
spring.datasource.url=jdbc:h2:file:$H2_DATA_DIR/h2db;DB_CLOSE_DELAY=-1;AUTO_SERVER=TRUE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.h2.console.path=/h2

# Hibernate auto DDL update
spring.jpa.hibernate.ddl-auto=update
EOF

# Optionally configure test properties (still in-memory)
echo "Configuring application-test.properties for in-memory H2 (for tests)..."
mkdir -p "$(dirname "$TEST_PROPERTIES")"
cat > "$TEST_PROPERTIES" <<EOF
# =========================================
# H2 In-Memory Database for Integration Tests
# =========================================
spring.datasource.url=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=create-drop
EOF

echo "DONE"
echo "Persistent H2 database path: $H2_DATA_DIR/h2db.mv.db"
echo "H2 console available at: http://localhost:8080/h2"
