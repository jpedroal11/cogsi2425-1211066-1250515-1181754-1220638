#!/usr/bin/env bash
set -e

# --- Configuration ---
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
MAVEN_VERSION=3.9.3
GRADLE_VERSION=8.3

echo "=== Verifying installed dependencies ==="

# Source environment
export JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH
export PATH=$PATH:/opt/maven/bin
export PATH=$PATH:/opt/gradle/latest/bin

echo "Java version:"
java -version

echo "Maven version:"
mvn -v

echo "Gradle version:"
gradle -v

echo "=== All dependencies verified! ==="
