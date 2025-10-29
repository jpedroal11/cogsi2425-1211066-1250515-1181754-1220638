#!/usr/bin/env bash
set -e

echo "=== Setting up H2 Database Server ==="

wget -q -O h2.zip https://github.com/h2database/h2database/releases/download/version-2.2.224/h2-2024-06-16.zip
sudo apt-get install -y unzip
sudo unzip -q h2.zip -d /opt/h2
rm h2.zip

echo "Setting up database directory..."
mkdir -p /vagrant/h2-data
sudo mkdir -p /var/lib/h2
sudo ln -s /vagrant/h2-data /var/lib/h2/data

sudo cat > /etc/systemd/system/h2.service << 'SERVICE_EOF'
[Unit]
Description=H2 Database Server
After=network.target

[Service]
Type=simple
User=vagrant
WorkingDirectory=/opt/h2/bin
ExecStart=/usr/bin/java -cp /opt/h2/bin/h2-2.2.224.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 -web -webAllowOthers -webPort 8081 -baseDir /var/lib/h2/data
Restart=on-failure
Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

[Install]
WantedBy=multi-user.target
SERVICE_EOF

echo "Configuring firewall..."
sudo apt-get install -y ufw
sudo ufw --force enable
sudo ufw allow from 192.168.56.11 to any port 9092
sudo ufw allow from 192.168.56.11 to any port 8081
sudo ufw allow ssh

echo "Starting H2 database service..."
sudo chown -R vagrant:vagrant /opt/h2
sudo chmod +x /opt/h2/bin/h2.sh
sudo systemctl daemon-reload
sudo systemctl enable h2
sudo systemctl start h2

echo "=== H2 Database Server Setup Complete ==="
echo "H2 TCP Server: 192.168.56.10:9092"
echo "H2 Web Console: 192.168.56.10:8081"