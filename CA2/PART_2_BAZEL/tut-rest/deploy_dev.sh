#!/bin/bash

set -e

APP_JAR=$1
LIB_JAR=$2
CONFIG_FILE=$3
OUTPUT_DIR=$4
VERSION=$5

echo "Starting deployment to DEV..."

# Create directory structure
mkdir -p "$OUTPUT_DIR/lib"

# Copy main JAR
cp "$APP_JAR" "$OUTPUT_DIR/payroll_app.jar"

# Copy library JAR
cp "$LIB_JAR" "$OUTPUT_DIR/lib/payroll_lib.jar"

# Process configuration file (token replacement)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
sed -e "s/@project.version@/$VERSION/g" \
    -e "s/@build.timestamp@/$TIMESTAMP/g" \
    "$CONFIG_FILE" > "$OUTPUT_DIR/application.properties"

# Create deployment info file
cat > "$OUTPUT_DIR/DEPLOYMENT_INFO.txt" << EOF
Deployment Information
----------------------
Application: Payroll Application
Version: $VERSION
Build Date: $TIMESTAMP
Environment: DEV
EOF

echo "Deployment completed: $OUTPUT_DIR"

