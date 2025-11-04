#!/bin/bash

echo "=========================================="
echo "Provisioning Database VM"
echo "=========================================="

# Update system
echo "Updating system packages..."
sudo apt-get update -qq

# Install Java
echo "Installing Java 17..."
sudo apt-get install -y openjdk-17-jdk-headless

# Create H2 directory
echo "Setting up H2 database..."
sudo mkdir -p /opt/h2
cd /opt/h2

# Download H2 database
echo "Downloading H2 database..."
sudo wget -q https://repo1.maven.org/maven2/com/h2database/h2/2.1.214/h2-2.1.214.jar -O h2.jar

# Create H2 service user
echo "Creating H2 service user..."
sudo useradd -r -s /bin/false h2 2>/dev/null || true

# Set permissions
sudo chown -R h2:h2 /opt/h2

# Create systemd service file
echo "Creating H2 systemd service..."
sudo tee /etc/systemd/system/h2.service > /dev/null <<EOF
[Unit]
Description=H2 Database Service
After=network.target

[Service]
Type=simple
User=h2
WorkingDirectory=/opt/h2
ExecStart=/usr/bin/java -cp /opt/h2/h2.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 -baseDir /opt/h2/data -ifNotExists
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create data directory
sudo mkdir -p /opt/h2/data
sudo chown -R h2:h2 /opt/h2/data

# Reload systemd and start H2
echo "Starting H2 service..."
sudo systemctl daemon-reload
sudo systemctl enable h2
sudo systemctl start h2

# Wait for H2 to start
sleep 5

# Install and configure firewall
echo "Configuring firewall..."
sudo apt-get install -y ufw

# Allow SSH
sudo ufw allow 22/tcp

# Allow H2 connection only from app VM
sudo ufw allow from 192.168.56.10 to any port 9092 proto tcp

# Enable firewall
sudo ufw --force enable

echo "=========================================="
echo "Database VM provisioning complete!"
echo "H2 is running on port 9092"
echo "Firewall configured to allow access only from 192.168.56.10"
echo "=========================================="

# Show H2 status
sudo systemctl status h2 --no-pager