#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Copy UWSGI service configuration
cp ../data/systemd/uwsgi.service /etc/systemd/system/

# Add system variables
mkdir -p /etc/systemd/system/uwsgi.service.d
printf "[Service]\nEnvironment=ENV_TYPE=$ENV_TYPE\nEnvironment=CONFIG_DIR=$CONFIG_DIR" > /etc/systemd/system/uwsgi.service.d/local.conf

# Enable and run the service
systemctl start uwsgi
systemctl enable uwsgi
