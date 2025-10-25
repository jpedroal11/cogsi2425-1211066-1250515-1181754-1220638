#!/usr/bin/env bash
set -e

# Project directory
PROJ_DIR="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2/app"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

echo "=== Building applications ==="

cd "$PROJ_DIR" || { echo "Project app directory $PROJ_DIR does not exist"; exit 1; }

# Ensure Gradle wrapper is executable
if [ -f "./gradlew" ]; then
    chmod +x ./gradlew
    # Force Gradle wrapper to use correct Java
    export JAVA_HOME=$JAVA_HOME
    export PATH=$JAVA_HOME/bin:$PATH
    echo "Using JAVA_HOME=$JAVA_HOME"
    ./gradlew clean build
else
    echo "Gradle wrapper not found, using system Gradle"
    export JAVA_HOME=$JAVA_HOME
    export PATH=$JAVA_HOME/bin:$PATH
    gradle clean build
fi

echo "=== Build complete ==="
