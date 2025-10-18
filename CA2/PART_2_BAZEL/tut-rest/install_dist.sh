#!/bin/bash

set -e

DEPLOY_JAR=$1
OUTPUT_DIR=$2
VERSION=$3

echo "Creating distribution..."

# Create directory structure
mkdir -p "$OUTPUT_DIR/bin"
mkdir -p "$OUTPUT_DIR/lib"

# Copy the fat JAR (deploy.jar contains all dependencies)
cp "$DEPLOY_JAR" "$OUTPUT_DIR/lib/payroll_app.jar"

# Create Linux/Mac script
cat > "$OUTPUT_DIR/bin/payroll_app" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
java -jar "$LIB_DIR/payroll_app.jar" "$@"
EOF

chmod +x "$OUTPUT_DIR/bin/payroll_app"

# Create Windows script
cat > "$OUTPUT_DIR/bin/payroll_app.bat" << 'EOF'
@echo off
set SCRIPT_DIR=%~dp0
set LIB_DIR=%SCRIPT_DIR%..\lib
java -jar "%LIB_DIR%\payroll_app.jar" %*
EOF

echo "Distribution created at: $OUTPUT_DIR"

