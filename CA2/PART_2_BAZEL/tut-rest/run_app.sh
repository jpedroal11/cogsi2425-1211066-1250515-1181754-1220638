#!/bin/bash

set -e

# Find workspace root by looking for BUILD.bazel file
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
WORKSPACE_ROOT="$SCRIPT_DIR"

# Search upwards for BUILD.bazel
while [ ! -f "$WORKSPACE_ROOT/BUILD.bazel" ] && [ "$WORKSPACE_ROOT" != "/" ]; do
    WORKSPACE_ROOT=$(dirname "$WORKSPACE_ROOT")
done

if [ ! -f "$WORKSPACE_ROOT/BUILD.bazel" ]; then
    echo "Error: Could not find workspace root (BUILD.bazel)"
    exit 1
fi

DIST_DIR="$WORKSPACE_ROOT/bazel-bin/dist"

if [ ! -f "$DIST_DIR/bin/payroll_app" ]; then
    echo "Error: Distribution not found at $DIST_DIR"
    echo "Run 'bazel build //:installDist' first."
    exit 1
fi

echo "Running application from distribution..."

# Run the distribution script
cd "$WORKSPACE_ROOT"
"$DIST_DIR/bin/payroll_app"

