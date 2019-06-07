#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Specify ES IP/Port
read -p "Provide the IP and port (IP:port) of the ES server: "

echo "$REPLY" > $CONFIG_DIR/ES_LOC

# Restart UWSGI for changes to take effect
systemctl restart uwsgi
