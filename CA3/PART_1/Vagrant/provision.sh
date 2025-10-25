#!/usr/bin/env bash
set -e

echo "Installing dependencies..."
/vagrant/scripts/git-clone.sh

echo "Building app..."
/vagrant/scripts/build-app.sh

echo "Starting services..."
/vagrant/scripts/start-services.sh
