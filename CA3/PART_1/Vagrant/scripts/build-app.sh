#!/usr/bin/env bash
set -e

# Project directory
PROJ_DIR="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2/app"

echo "=== Building applications ==="

# Navigate to the project app directory
cd "$PROJ_DIR" || { echo "Project app directory $PROJ_DIR/app does not exist"; exit 1; }

# Make gradlew executable if exists
if [ -f "./gradlew" ]; then
    chmod +x ./gradlew
    ./gradlew build
else
    echo "Gradle wrapper not found, using system Gradle"
    gradle build
fi

echo "=== Build complete ==="
