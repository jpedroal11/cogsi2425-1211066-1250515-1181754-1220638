#!/usr/bin/env bash
set -e
echo "Dependecies"
/vagrant/scripts/install-dependecies.sh
echo "Cloning"
/vagrant/scripts/git-clone.sh

echo "Building app..."
/vagrant/scripts/build-app.sh

echo "Starting services..."
/vagrant/scripts/start-services.sh
