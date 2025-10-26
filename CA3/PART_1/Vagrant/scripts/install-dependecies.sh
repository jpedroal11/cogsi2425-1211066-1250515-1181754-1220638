#!/usr/bin/env bash
set -e

# --- Configuration ---
PROJ_DIR="/home/vagrant/cogsi2425-1211066-1250515-1181754-1220638/CA3/PART_1/ca2-part2"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
MAVEN_VERSION=3.9.3
GRADLE_VERSION=8.3

echo "=== Updating system packages ==="
sudo apt-get update -y
sudo apt-get install -y curl zip unzip git wget tar openjdk-17-jdk

# --- Set Java environment ---
echo "=== Setting up Java environment ==="
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee /etc/profile.d/java.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/java.sh
sudo chmod +x /etc/profile.d/java.sh
export JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH
java -version

# --- Install Maven ---
echo "=== Installing Maven $MAVEN_VERSION ==="
wget -q https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -P /tmp
sudo tar xf /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C /opt
sudo ln -sf /opt/apache-maven-$MAVEN_VERSION /opt/maven
echo 'export PATH=$PATH:/opt/maven/bin' | sudo tee /etc/profile.d/maven.sh
sudo chmod +x /etc/profile.d/maven.sh
export PATH=$PATH:/opt/maven/bin
mvn -v

# --- Install Gradle ---
echo "=== Installing Gradle $GRADLE_VERSION ==="
wget -q https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip -O /tmp/gradle-$GRADLE_VERSION-bin.zip
sudo mkdir -p /opt/gradle
sudo unzip -o /tmp/gradle-$GRADLE_VERSION-bin.zip -d /opt/gradle
sudo ln -sf /opt/gradle/gradle-$GRADLE_VERSION /opt/gradle/latest
echo 'export PATH=$PATH:/opt/gradle/latest/bin' | sudo tee /etc/profile.d/gradle.sh
sudo chmod +x /etc/profile.d/gradle.sh
export PATH=$PATH:/opt/gradle/latest/bin
gradle -v


