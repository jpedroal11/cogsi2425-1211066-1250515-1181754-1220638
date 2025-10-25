#!/usr/bin/env bash
set -e

echo "==== Updating system packages ===="
sudo apt-get update -y
sudo apt-get install -y curl zip unzip git wget tar


echo "==== Installing Java 17 ===="
sudo apt-get install -y openjdk-17-jdk
java -version


echo "==== Installing Maven 3.9.3 ===="
MAVEN_VERSION=3.9.3
wget -q https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -P /tmp
sudo tar xf /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C /opt
sudo ln -sf /opt/apache-maven-$MAVEN_VERSION /opt/maven
# Add Maven to PATH
echo 'export PATH=$PATH:/opt/maven/bin' | sudo tee /etc/profile.d/maven.sh
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
mvn -v

echo "==== Installing Gradle 9.1.0 ===="
GRADLE_VERSION=9.1.0
wget -q https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip -P /tmp
sudo unzip -d /opt/gradle /tmp/gradle-$GRADLE_VERSION-bin.zip
sudo ln -sf /opt/gradle/gradle-$GRADLE_VERSION /opt/gradle/latest
# Add Gradle to PATH
echo 'export PATH=$PATH:/opt/gradle/latest/bin' | sudo tee /etc/profile.d/gradle.sh
sudo chmod +x /etc/profile.d/gradle.sh
source /etc/profile.d/gradle.sh
gradle -v

echo "==== Installation complete! ===="
