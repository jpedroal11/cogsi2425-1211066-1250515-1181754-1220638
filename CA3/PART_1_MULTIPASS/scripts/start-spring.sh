#!/usr/bin/env bash
set -e

# Configuration
PROJ_DIR="${PROJ_DIR:-/home/ubuntu/workspace}"
REPO_NAME="cogsi2425-1211066-1250515-1181754-1220638"
PROJ_ROOT="$PROJ_DIR/$REPO_NAME/CA3/PART_1/ca2-part2"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

echo "=== Starting Spring Boot application ==="

# Source environment
export JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

cd "$PROJ_ROOT" || { echo "ERROR: Project directory not found"; exit 1; }

# Kill existing process if running
if [ -f /home/ubuntu/spring-app.pid ]; then
    OLD_PID=$(cat /home/ubuntu/spring-app.pid)
    if kill -0 $OLD_PID 2>/dev/null; then
        echo "Stopping existing Spring Boot process (PID: $OLD_PID)..."
        kill $OLD_PID
        sleep 2
    fi
    rm /home/ubuntu/spring-app.pid
fi

# Start application in background
echo "Starting Spring Boot application..."
nohup ./gradlew bootRun > /home/ubuntu/spring-app.log 2>&1 &
echo $! > /home/ubuntu/spring-app.pid

sleep 5

VM_IP=$(hostname -I | awk '{print $1}')
echo "✓ Spring Boot application started!"
echo "  PID: $(cat /home/ubuntu/spring-app.pid)"
echo "  Logs: /home/ubuntu/spring-app.log"
echo "  Access: http://$VM_IP:8080"
echo "  H2 Console: http://$VM_IP:8080/h2"
