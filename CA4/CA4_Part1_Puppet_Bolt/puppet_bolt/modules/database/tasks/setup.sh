#!/bin/bash
# Database setup: H2 Database

set -e

H2_VERSION="2.4.240"
H2_DIR="/opt/h2"
H2_DATA="/home/devuser/h2-data"

echo "Installing Java..."
apt-get update -qq
apt-get install -y -qq default-jre curl > /dev/null
echo "  ✓ Java installed"

echo "Downloading H2 Database v${H2_VERSION}..."
mkdir -p $H2_DIR
if [ ! -f "$H2_DIR/h2-${H2_VERSION}.jar" ]; then
  curl -sL "https://github.com/h2database/h2database/releases/download/version-${H2_VERSION}/h2-${H2_VERSION}.jar" \
    -o "$H2_DIR/h2-${H2_VERSION}.jar"
  echo "  ✓ H2 Database downloaded"
else
  echo "  ✓ H2 Database already exists"
fi

echo "Creating H2 data directory..."
mkdir -p $H2_DATA
chown -R devuser:developers $H2_DATA
chmod 0750 $H2_DATA
echo "  ✓ Data directory created with correct permissions (0750)"

echo "Creating H2 systemd service..."
cat > /etc/systemd/system/h2.service << 'EOF'
[Unit]
Description=H2 Database Server
After=network.target

[Service]
Type=simple
User=devuser
Group=developers
WorkingDirectory=/home/devuser
ExecStart=/usr/bin/java -cp /opt/h2/h2-2.4.240.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 -web -webAllowOthers -webPort 8082 -baseDir /home/devuser/h2-data
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable h2
systemctl restart h2
echo "  ✓ H2 service created and started"

# Wait for H2 to start
echo "Waiting for H2 to start..."
for i in {1..10}; do
  if nc -z localhost 9092 2>/dev/null; then
    echo "  ✓ H2 is running on port 9092"
    break
  fi
  sleep 2
done

echo ""
echo "Database configuration completed successfully!"
echo "  - TCP Server: port 9092"
echo "  - Web Console: http://192.168.56.13:8082"

