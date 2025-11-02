#!/usr/bin/env bash
set -e
GRADLE_VERSION=8.3
PROJ_DIR="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2/app"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
PROJ_ROOT="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2"

echo "=== Building applications ==="

cd "$PROJ_DIR" || { echo "Project app directory $PROJ_DIR does not exist"; exit 1; }

cd "$PROJ_ROOT"
echo "=== Generating/updating Gradle wrapper to $GRADLE_VERSION ==="
gradle wrapper --gradle-version $GRADLE_VERSION
chmod +x ./gradlew

if [ -f "./gradlew" ]; then
    chmod +x ./gradlew
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