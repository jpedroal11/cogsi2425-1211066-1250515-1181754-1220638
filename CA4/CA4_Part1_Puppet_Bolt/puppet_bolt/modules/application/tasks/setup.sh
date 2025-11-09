#!/bin/bash
# Application setup: Spring Boot

set -e

DB_HOST="${PT_db_host:-192.168.56.13}"
APP_DIR="/home/devuser/app"
REPO_URL="https://github.com/spring-guides/tut-rest.git"

echo "Installing Java 17 and Maven..."
apt-get update -qq
apt-get install -y -qq openjdk-17-jdk maven git curl netcat > /dev/null
echo "  ✓ Java 17, Maven and Git installed"

echo "Cloning Spring Boot repository..."
if [ ! -d "$APP_DIR" ]; then
  sudo -u devuser git clone $REPO_URL $APP_DIR
  echo "  ✓ Repository cloned"
else
  echo "  ✓ Repository already exists"
fi

echo "Configuring application.properties..."
mkdir -p $APP_DIR/rest/src/main/resources
cat > $APP_DIR/rest/src/main/resources/application.properties << EOF
# Database Configuration
spring.datasource.url=jdbc:h2:tcp://${DB_HOST}:9092//home/devuser/h2-data/test;IFEXISTS=FALSE;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# JPA Configuration
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update

# H2 Console (disabled on app VM)
spring.h2.console.enabled=false

# Server Configuration
server.port=8080
EOF
chown devuser:developers $APP_DIR/rest/src/main/resources/application.properties
echo "  ✓ application.properties configured for remote H2"

echo "Building Spring Boot application (this may take 3-5 minutes)..."
cd $APP_DIR/rest

# Fix ownership and permissions
chown -R devuser:developers $APP_DIR
chmod +x ../mvnw

# Run build with Maven
sudo -u devuser ../mvnw clean package -DskipTests

# Find the JAR file
JAR_FILE=$(find $APP_DIR/rest/target -name "*.jar" -type f | head -1)

if [ -z "$JAR_FILE" ]; then
  echo "  ✗ ERROR: JAR file not found after build!"
  ls -la $APP_DIR/rest/target/ || echo "target directory not found"
  exit 1
fi

echo "  ✓ Application built successfully: $(basename $JAR_FILE)"

echo "Creating Spring Boot systemd service..."
cat > /etc/systemd/system/springboot.service << EOF
[Unit]
Description=Spring Boot REST Application
After=network.target

[Service]
Type=simple
User=devuser
Group=developers
WorkingDirectory=/home/devuser/app/rest
ExecStartPre=/bin/sleep 10
ExecStart=/usr/bin/java -jar ${JAR_FILE}
Restart=on-failure
RestartSec=10
Environment="JAVA_OPTS=-Xmx512m"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable springboot
systemctl restart springboot
echo "  ✓ Spring Boot service created and started"

# Wait for app to start
echo "Waiting for Spring Boot to start..."
for i in {1..30}; do
  if curl -s http://localhost:8080/employees > /dev/null 2>&1; then
    echo "  ✓ Spring Boot is running on port 8080"
    break
  fi
  sleep 2
done

echo ""
echo "Application configuration completed successfully!"
echo "  - REST API: http://192.168.56.12:8080/employees"

