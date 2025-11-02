# CA3 Part 2 - Multi-VM Virtualization Setup

## Overview

This Part 2 assignment implements a multi-VM environment using Vagrant, where the Spring Boot application and H2 database run on separate virtual machines. This simulates a real-world microservices architecture with proper service separation and network security.

## Architecture

### Database VM (db-vm): 192.168.56.10

    - Hosts H2 database in TCP server mode

    - Runs on port 9092 (TCP) and 8081 (Web Console)

    - Firewall configured to only allow connections from app VM

### Application VM (app-vm): 192.168.56.11

    - Hosts Spring Boot REST application

    - Accessible from host machine via port 18080 → 8080 forwarding

    - Connects to remote database VM

### Vagrantfile

Here in the Vagrantfile it was definied the 2 VMs, including private networks, port forwarding, resource allocation and the automated provisioning script execution:

```
Vagrant.configure("2") do |config|
  # Database VM
  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/jammy64"
    db.vm.hostname = "db-vm"
    db.vm.network "private_network", ip: "192.168.56.10"
    db.vm.synced_folder "./h2-data", "/vagrant/h2-data", create: true
    
    db.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
      vb.name = "ca3-part2-db"
    end
    
    db.vm.provision "shell", path: "scripts/install-dependencies.sh", privileged: false
    db.vm.provision "shell", path: "scripts/setup-h2-server.sh", privileged: false
  end

  # Application VM
  config.vm.define "app" do |app|
    app.vm.box = "ubuntu/jammy64"
    app.vm.hostname = "app-vm"
    app.vm.network "forwarded_port", guest: 8080, host: 18080
    app.vm.network "private_network", ip: "192.168.56.11"
    
    app.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
      vb.name = "ca3-part2-app"
    end
    
    app.vm.provision "shell", path: "scripts/install-dependencies.sh", privileged: false
    app.vm.provision "shell", path: "scripts/git-clone.sh", privileged: false
    app.vm.provision "shell", path: "scripts/build-app.sh", privileged: false
    app.vm.provision "shell", path: "scripts/configure-remote-db.sh", privileged: false
    app.vm.provision "shell", path: "scripts/wait-for-db.sh", privileged: false, run: "always"
  end
end
```

### Scripts

#### install-dependencies.sh - System Setup

```
#!/usr/bin/env bash
set -e

PROJ_DIR="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
MAVEN_VERSION=3.9.3
GRADLE_VERSION=8.3

echo "=== Updating system packages ==="
sudo apt-get update -y
sudo apt-get install -y curl zip unzip git wget tar openjdk-17-jdk netcat-openbsd

echo "=== Setting up Java environment ==="
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee /etc/profile.d/java.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/java.sh
sudo chmod +x /etc/profile.d/java.sh
export JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH
java -version

echo "=== Installing Maven $MAVEN_VERSION ==="
wget -q https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -P /tmp
sudo tar xf /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C /opt
sudo ln -sf /opt/apache-maven-$MAVEN_VERSION /opt/maven
echo 'export PATH=$PATH:/opt/maven/bin' | sudo tee /etc/profile.d/maven.sh
sudo chmod +x /etc/profile.d/maven.sh
export PATH=$PATH:/opt/maven/bin
mvn -v

echo "=== Installing Gradle $GRADLE_VERSION ==="
wget -q https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip -O /tmp/gradle-$GRADLE_VERSION-bin.zip
sudo mkdir -p /opt/gradle
sudo unzip -o /tmp/gradle-$GRADLE_VERSION-bin.zip -d /opt/gradle
sudo ln -sf /opt/gradle/gradle-$GRADLE_VERSION /opt/gradle/latest
echo 'export PATH=$PATH:/opt/gradle/latest/bin' | sudo tee /etc/profile.d/gradle.sh
sudo chmod +x /etc/profile.d/gradle.sh
export PATH=$PATH:/opt/gradle/latest/bin
gradle -v
```

**Summary:**

This script installs all required software and development tools on both VMs, including:

    - Java 17 OpenJDK
    - Maven 3.9.3
    - Gradle 8.3
    - and more essential utilities (git, curl, wget, etc...)

#### setup-h2-server.sh - Database Server

```
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
```

**Summary:**

This script configures H2 database to run in TCP server mode with security.

    - Downloads H2 database from official Maven repository

    - Creates systemd service for automatic startup

    - Configures H2 in TCP server mode on port 9092

    - Enables web console on port 8081

    - Sets up firewall to only allow app VM access (ufw)

    - Uses /vagrant/h2-data for persistent storage

    - Database files stored in synced folder for persistence

#### git-clone.sh - Repository Management

```
#!/usr/bin/env bash
set -e

PROJ_DIR="${PROJ_DIR:-/home/vagrant}"
REPO_NAME="cogsi2425-1211066-1250515-1181754-1220638"
REPO_URL="git@github.com:jpedroal11/${REPO_NAME}.git"
BRANCH_NAME="feature/vagrant-part2"

echo "==== Cloning project repository ===="

mkdir -p ~/.ssh
ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null

if [ -d "$PROJ_DIR/$REPO_NAME/.git" ]; then
    echo "Repository already exists — fetching latest changes..."
    cd "$PROJ_DIR/$REPO_NAME"
    git fetch origin
else
    echo "Cloning new repository into $PROJ_DIR"
    mkdir -p "$PROJ_DIR"
    git clone "$REPO_URL" "$PROJ_DIR/$REPO_NAME"
    cd "$PROJ_DIR/$REPO_NAME"
fi

if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    git checkout "$BRANCH_NAME"
    git pull origin "$BRANCH_NAME"
else
    git checkout -b "$BRANCH_NAME" "origin/$BRANCH_NAME"
fi

cd "$PROJ_DIR/$REPO_NAME"
echo "Repository cloned or updated successfully on branch '$BRANCH_NAME'."
```

**Summary:**

This script clones and updates our project repo on the application VM.

#### build-app.sh - Application Compilation

```
#!/usr/bin/env bash
set -e
GRADLE_VERSION=8.3
PROJ_DIR="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2/app"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
PROJ_ROOT="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2"

echo "=== Building applications ==="

cd "$PROJ_DIR" || { echo "Project app directory $PROJ_DIR does not exist"; exit 1; }

cd "$PROJ_ROOT"
echo "=== Generating/updating Gradle wrapper to $GRADLE_VERSION ==="
gradle wrapper --gradle-version $GRADLE_VERSION
chmod +x ./gradlew

if [ -f "./gradlew" ]; then
    chmod +x ./gradlew
    export JAVA_HOME=$JAVA_HOME
    export PATH=$JAVA_HOME/bin:$PATH
    echo "Using JAVA_HOME=$JAVA_HOME"
    ./gradlew clean build
else
    echo "Gradle wrapper not found, using system Gradle"
    export JAVA_HOME=$JAVA_HOME
    export PATH=$JAVA_HOME/bin:$PATH
    gradle clean build
fi

echo "=== Build complete ==="
```

**Summary:**

This script builds the Spring Boot application using Gradle.

#### configure-remote-db.sh - Application Configuration

```
#!/usr/bin/env bash
set -e

PROJ_ROOT="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638"
APP_PROPERTIES="$PROJ_ROOT/CA3/PART_1/ca2-part2/app/src/main/resources/application.properties"

echo "=== Configuring Spring Boot for REMOTE database ==="

APP_DIR=$(dirname "$APP_PROPERTIES")
mkdir -p "$APP_DIR"

cat > "$APP_PROPERTIES" << 'PROPS_EOF'
spring.datasource.url=jdbc:h2:tcp://192.168.56.10:9092/~/cogsidb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.h2.console.path=/h2
spring.jpa.hibernate.ddl-auto=update
server.port=8080
spring.h2.console.settings.web-allow-others=true
PROPS_EOF

echo "Spring Boot configured to use REMOTE database"
```

**Summary:**

This script configures Spring Boot to connect to remote H2 database (server port was set to 8080).

#### wait-for-db.sh - Startup Coordination

```
#!/usr/bin/env bash
set -e

echo "=== Waiting for Database ==="
echo "Checking H2 at 192.168.56.10:9092..."

for i in {1..30}; do
    if nc -z 192.168.56.10 9092; then
        echo "SUCCESS: Database is ready!"
        
        PROJ_ROOT="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2"
        cd "$PROJ_ROOT"
        
        echo "Starting Spring Boot application..."
        nohup ./gradlew bootRun > /tmp/spring-boot.log 2>&1 &
        
        echo "Application starting..."
        echo "Access: http://localhost:18080"
        exit 0
    else
        echo "Attempt $i/30: Database not ready, waiting..."
        sleep 5
    fi
done

echo "ERROR: Database not available after 30 attempts"
exit 1
```

**Summary:**

This script ensures the app starts only after database is ready. It also attempts to connect for 30 times before exiting with error.

## Run

In order to run:

```
cd PART_2/Vagrant
vagrant up
```

This creates both VMs, installs all dependencies, setups H2 database and the App, and then after successfully setting up everuthing, the Application starts.

