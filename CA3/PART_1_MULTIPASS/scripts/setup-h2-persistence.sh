#!/usr/bin/env bash
set -e

# Directories
H2_DATA_DIR="/home/ubuntu/h2-data"
PROJ_DIR="${PROJ_DIR:-/home/ubuntu/workspace}"
REPO_NAME="cogsi2425-1211066-1250515-1181754-1220638"
APP_PROPERTIES="$PROJ_DIR/$REPO_NAME/CA3/PART_1/ca2-part2/app/src/main/resources/application.properties"
TEST_PROPERTIES="$PROJ_DIR/$REPO_NAME/CA3/PART_1/ca2-part2/app/src/integrationTest/resources/application-test.properties"

echo "=== Setting up persistent H2 database ==="

# Ensure H2 data directory exists
mkdir -p "$H2_DATA_DIR"
chmod 777 "$H2_DATA_DIR"

# Create application.properties directory
APP_DIR=$(dirname "$APP_PROPERTIES")
mkdir -p "$APP_DIR"

# Configure persistent H2 database
echo "Configuring application.properties for persistent H2..."

cat > "$APP_PROPERTIES" <<'EOF'
# =========================================
# H2 Persistent Database Configuration
# =========================================
spring.datasource.url=jdbc:h2:file:/home/ubuntu/h2-data/h2db;DB_CLOSE_DELAY=-1;AUTO_SERVER=TRUE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.h2.console.path=/h2

# Hibernate auto DDL update
spring.jpa.hibernate.ddl-auto=update
EOF

# Configure test properties (in-memory)
echo "Configuring application-test.properties for in-memory H2..."
mkdir -p "$(dirname "$TEST_PROPERTIES")"

cat > "$TEST_PROPERTIES" <<'EOF'
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

echo "✓ H2 persistence configured"
echo "  Database path: $H2_DATA_DIR/h2db.mv.db"
echo "  H2 console: http://VM_IP:8080/h2"
