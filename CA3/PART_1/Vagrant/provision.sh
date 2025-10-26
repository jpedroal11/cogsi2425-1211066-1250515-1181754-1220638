#!/usr/bin/env bash
set -e

echo "==== Installing dependencies ===="
/vagrant/scripts/install-dependecies.sh

echo "==== Cloning repository ===="
/vagrant/scripts/git-clone.sh

echo "==== Configuring persistent H2 storage ===="
/vagrant/scripts/setup-h2-persistence.sh

echo "==== Building app ===="
/vagrant/scripts/build-app.sh

echo "==== Start ===="
/vagrant/scripts/start-services.sh