#!/bin/bash
# setup-app.sh - Configure Spring Boot Application on app VM

set -e

DB_IP=$1
REPO_URL=$2

if [ -z "$DB_IP" ]; then
    echo "ERROR: DB_IP not provided"
    echo "Usage: $0 <DB_IP> <REPO_URL>"
    exit 1
fi

echo "=== Configuring Spring Boot Application ==="
echo "Database IP: $DB_IP"

# Clone repository
echo "[1/5] Cloning repository..."
cd ~
if [ -n "$REPO_URL" ]; then
    git clone "$REPO_URL" repo
    cd repo/CA2/PART_2/ca2-part2
else
    echo "WARNING: No repo URL provided, expecting project at ~/ca2-part2"
    cd ~/ca2-part2
fi

PROJECT_DIR=$(pwd)
echo "Project directory: $PROJECT_DIR"

# Create wait-for-db.sh
echo "[2/5] Creating startup check script..."
cat > ~/wait-for-db.sh <<'EOF'
#!/bin/bash
set -e

DB_HOST=$1
DB_PORT=${2:-9092}

echo "Waiting for H2 database at $DB_HOST:$DB_PORT..."

MAX_WAIT=60
WAIT_TIME=0

while [ $WAIT_TIME -lt $MAX_WAIT ]; do
    if nc -z $DB_HOST $DB_PORT 2>/dev/null; then
        echo "SUCCESS: H2 available"
        exit 0
    fi
    echo "Trying... ($WAIT_TIME/$MAX_WAIT seconds)"
    sleep 2
    WAIT_TIME=$((WAIT_TIME + 2))
done

echo "ERROR: Timeout waiting for database"
exit 1
EOF

chmod +x ~/wait-for-db.sh

# Configure application.properties
echo "[3/5] Configuring application.properties..."
mkdir -p "$PROJECT_DIR/app/src/main/resources"

cat > "$PROJECT_DIR/app/src/main/resources/application.properties" <<EOF
spring.datasource.url=jdbc:h2:tcp://${DB_IP}:9092/~/h2-data/payroll
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

spring.h2.console.enabled=false

spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

server.port=8080
EOF

echo "Application configured with DB_IP: $DB_IP"

# Configure JAVA_HOME
echo "[4/5] Configuring JAVA_HOME..."
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc

# Set executable permission and configure Gradle
echo "[5/5] Configuring Gradle..."
cd "$PROJECT_DIR"
chmod +x gradlew
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
./gradlew wrapper --gradle-version=8.5

echo "SUCCESS: Application setup complete"
echo ""
echo "To start the application:"
echo "  cd ~"
echo "  ./wait-for-db.sh $DB_IP 9092"
echo "  cd $PROJECT_DIR"
echo "  nohup ./gradlew bootRun --no-daemon > ~/app.log 2>&1 &"
