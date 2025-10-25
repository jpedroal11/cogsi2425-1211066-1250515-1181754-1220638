#!/usr/bin/env bash
set -e

# --- Configuration ---
PROJ_DIR="${1:-/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2/app}"
PID_FILE="/tmp/ca2-app.pid"

cd "$PROJ_DIR"

# --- Find JAR ---
JAR_FILE=$(find build/libs -name "*.jar" | head -n 1)
[ -z "$JAR_FILE" ] && echo "❌ No JAR found. Build first." && exit 1

# --- Stop existing instance ---
[ -f "$PID_FILE" ] && kill $(cat "$PID_FILE") 2>/dev/null || true
rm -f "$PID_FILE"

# --- Start new instance ---
nohup java -jar "$JAR_FILE" >/dev/null 2>&1 &
echo $! > "$PID_FILE"

echo "Application started (PID: $(cat $PID_FILE))"
