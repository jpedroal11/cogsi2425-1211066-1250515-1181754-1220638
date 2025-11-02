#!/usr/bin/env bash
set -e

# Configuration
GRADLE_VERSION=8.3
PROJ_DIR="${PROJ_DIR:-/home/ubuntu/workspace}"
REPO_NAME="cogsi2425-1211066-1250515-1181754-1220638"
PROJ_ROOT="$PROJ_DIR/$REPO_NAME/CA3/PART_1/ca2-part2"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

echo "=== Building Spring Boot application ==="

# Source environment
export JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH
export PATH=$PATH:/opt/gradle/latest/bin

cd "$PROJ_ROOT" || { echo "ERROR: Project directory not found: $PROJ_ROOT"; exit 1; }

# Generate Gradle wrapper
echo "Generating Gradle wrapper (version $GRADLE_VERSION)..."
gradle wrapper --gradle-version $GRADLE_VERSION
chmod +x ./gradlew

# Build the project
echo "Building project with Gradle..."
./gradlew clean build

echo "✓ Build complete!"
