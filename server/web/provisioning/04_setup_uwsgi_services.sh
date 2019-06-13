#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Copy service configurations
cp ../data/systemd/opendal-production.service /etc/systemd/system/
cp ../data/systemd/opendal-staging.service /etc/systemd/system/

# Enable and run the production service (staging can be started manually)
systemctl start opendal-production
systemctl enable opendal-production
