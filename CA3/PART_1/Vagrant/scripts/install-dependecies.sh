#!/usr/bin/env bash
set -e

echo "==== Updating system packages ===="
sudo apt-get update -y
sudo apt-get install -y curl zip unzip git wget tar

echo "==== Installing Java 17 ===="
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' | sudo tee /etc/profile.d/java.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/java.sh
sudo chmod +x /etc/profile.d/java.sh
source /etc/profile.d/java.sh
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

echo "==== Installing Gradle 8.3 ===="
GRADLE_VERSION=8.3
wget -q https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip -P /tmp
sudo unzip -d /opt/gradle /tmp/gradle-$GRADLE_VERSION-bin.zip
sudo ln -sf /opt/gradle/gradle-$GRADLE_VERSION /opt/gradle/latest
# Add Gradle to PATH
echo 'export PATH=$PATH:/opt/gradle/latest/bin' | sudo tee /etc/profile.d/gradle.sh
sudo chmod +x /etc/profile.d/gradle.sh
source /etc/profile.d/gradle.sh
gradle -v

echo "==== Updating Gradle wrapper in project to 8.3 ===="
# Navigate to your project directory (update path if needed)
PROJECT_DIR="$HOME/cogsi2425-1211066-1250515-1181754-1220638/CA2/PART_2/ca2-part2"
cd "$PROJECT_DIR"

# Update gradle-wrapper.properties to use Gradle 8.3
sed -i 's/gradle-9\.[0-9]\+/-8.3/' gradle/wrapper/gradle-wrapper.properties

# Regenerate wrapper scripts
./gradlew wrapper --gradle-version 8.3
chmod +x ./gradlew

echo "==== Build project with Gradle 8.3 ===="
./gradlew clean build
./gradlew bootJar

echo "==== Installation and build complete! ===="
