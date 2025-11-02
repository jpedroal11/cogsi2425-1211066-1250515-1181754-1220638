#!/bin/bash
# setup-db.sh - Configure H2 Database Server on db VM

set -e

echo "=== Configuring H2 Database Server ==="

# Download H2
echo "[1/4] Downloading H2..."
cd ~
wget -q https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar
mkdir -p ~/h2-data

# Create systemd service
echo "[2/4] Creating systemd service..."
sudo tee /etc/systemd/system/h2-server.service > /dev/null <<'EOF'
[Unit]
Description=H2 Database Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/usr/bin/java -cp /home/ubuntu/h2-2.2.224.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 -baseDir /home/ubuntu/h2-data -ifNotExists
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start H2
echo "[3/4] Starting H2 service..."
sudo systemctl daemon-reload
sudo systemctl enable h2-server.service
sudo systemctl start h2-server.service

# Verify
echo "[4/4] Verifying H2 service..."
sleep 3
if nc -z localhost 9092; then
    echo "SUCCESS: H2 Database Server running on port 9092"
    sudo systemctl status h2-server.service --no-pager
else
    echo "ERROR: H2 failed to start"
    exit 1
fi
