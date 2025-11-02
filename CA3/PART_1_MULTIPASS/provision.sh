#!/usr/bin/env bash
set -e

# Source environment variables
source /etc/profile.d/java.sh
source /etc/profile.d/maven.sh
source /etc/profile.d/gradle.sh

echo "========================================"
echo "CA3 Part 1 - Multipass Provisioning"
echo "========================================"

# Read environment variables
CLONE_REPO=${CLONE_REPO:-true}
BUILD_APP=${BUILD_APP:-true}
START_APP=${START_APP:-false}

# Script directory
SCRIPT_DIR="/home/ubuntu/scripts"

# Step 1: Verify dependencies
echo ""
echo "Step 1/5: Verifying dependencies..."
if [ -f "$SCRIPT_DIR/install-dependencies.sh" ]; then
    $SCRIPT_DIR/install-dependencies.sh
else
    echo "Warning: install-dependencies.sh not found"
fi

# Step 2: Clone repository (if enabled)
if [ "$CLONE_REPO" = "true" ]; then
    echo ""
    echo "Step 2/5: Cloning repository..."
    if [ -f "$SCRIPT_DIR/git-clone.sh" ]; then
        $SCRIPT_DIR/git-clone.sh
    else
        echo "ERROR: git-clone.sh not found!"
        exit 1
    fi
else
    echo ""
    echo "Step 2/5: Skipping repository clone (CLONE_REPO=false)"
fi

# Step 3: Setup H2 persistence
echo ""
echo "Step 3/5: Configuring H2 persistence..."
if [ -f "$SCRIPT_DIR/setup-h2-persistence.sh" ]; then
    $SCRIPT_DIR/setup-h2-persistence.sh
else
    echo "Warning: setup-h2-persistence.sh not found"
fi

# Step 4: Build application (if enabled)
if [ "$BUILD_APP" = "true" ]; then
    echo ""
    echo "Step 4/5: Building application..."
    if [ -f "$SCRIPT_DIR/build-app.sh" ]; then
        $SCRIPT_DIR/build-app.sh
    else
        echo "ERROR: build-app.sh not found!"
        exit 1
    fi
else
    echo ""
    echo "Step 4/5: Skipping build (BUILD_APP=false)"
fi

# Step 5: Start application (if enabled)
if [ "$START_APP" = "true" ]; then
    echo ""
    echo "Step 5/5: Starting application..."
    if [ -f "$SCRIPT_DIR/start-spring.sh" ]; then
        $SCRIPT_DIR/start-spring.sh
    else
        echo "Warning: start-spring.sh not found"
    fi
else
    echo ""
    echo "Step 5/5: Application not auto-started (START_APP=false)"
fi

echo ""
echo "========================================"
echo "✓ Provisioning complete!"
echo "========================================"
VM_IP=$(hostname -I | awk '{print $1}')
echo "VM IP: $VM_IP"
echo ""
echo "Useful commands:"
echo "  Start app: /home/ubuntu/scripts/start-spring.sh"
echo "  View logs: tail -f /home/ubuntu/spring-app.log"
echo ""
echo "Access points (from host):"
echo "  Spring Boot: http://$VM_IP:8080"
echo "  H2 Console:  http://$VM_IP:8080/h2"
echo "  JDBC URL:    jdbc:h2:file:/home/ubuntu/h2-data/h2db"
echo "========================================"
