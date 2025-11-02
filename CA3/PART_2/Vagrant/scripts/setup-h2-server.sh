#!/usr/bin/env bash
set -e

VERSION="2.2.224"
URL="https://repo1.maven.org/maven2/com/h2database/h2/${VERSION}/h2-${VERSION}.jar"

echo "Downloading H2 version ${VERSION} from ${URL}"
cd /tmp
wget -O h2.jar "$URL"

sudo mkdir -p /opt/h2
sudo mv h2.jar /opt/h2/h2-${VERSION}.jar
sudo chown -R vagrant:vagrant /opt/h2

# Then create the service, pointing to the jar:
sudo tee /etc/systemd/system/h2.service > /dev/null << EOF
[Unit]
Description=H2 Database Server
After=network.target

[Service]
Type=simple
User=vagrant
ExecStart=/usr/bin/java -cp /opt/h2/h2-${VERSION}.jar org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 -web -webAllowOthers -webPort 8081 -baseDir /vagrant/h2-data
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# enable & start service
sudo systemctl daemon-reload
sudo systemctl enable h2
sudo systemctl start h2
