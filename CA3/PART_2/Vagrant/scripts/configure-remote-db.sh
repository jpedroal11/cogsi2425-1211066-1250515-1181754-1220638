#!/usr/bin/env bash
set -e

PROJ_ROOT="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638"
APP_PROPERTIES="$PROJ_ROOT/CA3/PART_1/ca2-part2/app/src/main/resources/application.properties"

echo "=== Configuring Spring Boot for REMOTE database ==="

APP_DIR=$(dirname "$APP_PROPERTIES")
mkdir -p "$APP_DIR"

cat > "$APP_PROPERTIES" << 'PROPS_EOF'
spring.datasource.url=jdbc:h2:tcp://192.168.56.10:9092/~/cogsidb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.h2.console.path=/h2
spring.jpa.hibernate.ddl-auto=update
server.port=8080
spring.h2.console.settings.web-allow-others=true
PROPS_EOF

echo "Spring Boot configured to use REMOTE database"