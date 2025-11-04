#!/bin/bash

echo "=========================================="
echo "Provisioning Application VM"
echo "=========================================="

# Update system
echo "Updating system packages..."
sudo apt-get update -qq

# Install Java and Git
echo "Installing Java 17 and Git..."
sudo apt-get install -y openjdk-17-jdk git

# Install netcat for connection testing
echo "Installing netcat..."
sudo apt-get install -y netcat

# Clone repository
echo "Cloning repository..."
cd /home/vagrant

REPO_DIR="cogsi2425-1211066-1250515-1181754-1220638"

if [ ! -d "$REPO_DIR" ]; then
  git clone https://github.com/jpedroal11/${REPO_DIR}.git
  chown -R vagrant:vagrant $REPO_DIR
  echo "Repository cloned successfully"
else
  echo "Repository already exists, skipping clone"
fi

# Update Spring Boot application.properties
echo "Updating application.properties for H2 server mode..."
PROPERTIES_FILE="${REPO_DIR}/CA3/PART_1/ca2-part2/src/main/resources/application.properties"

# Backup original if it exists
if [ -f "$PROPERTIES_FILE" ]; then
  cp "$PROPERTIES_FILE" "${PROPERTIES_FILE}.backup"
  echo "Original application.properties backed up"
fi

# Create new application.properties with H2 server mode configuration
cat > "$PROPERTIES_FILE" <<'PROPS'
# Server Configuration
server.port=8080

# H2 Database Configuration - Server Mode
spring.datasource.url=jdbc:h2:tcp://192.168.56.11:9092/~/test
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# JPA/Hibernate Configuration
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# H2 Console (optional - for debugging)
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
PROPS

echo "application.properties updated successfully"

# Create startup script
echo "Creating startup script..."
cat > /home/vagrant/start-app.sh <<'EOF'
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
EOF

chmod +x /home/vagrant/start-app.sh
chown vagrant:vagrant /home/vagrant/start-app.sh

echo "=========================================="
echo "Application VM provisioning complete!"
echo "Repository location: /home/vagrant/${REPO_DIR}"
echo "Project location: /home/vagrant/${REPO_DIR}/CA3/PART_1/ca2-part2"
echo "application.properties updated with H2 server mode configuration"
echo "To start the application: ./start-app.sh"
echo "=========================================="