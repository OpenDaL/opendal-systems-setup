#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Set the environment type:
read -p "Please provide the environment type (staging/production): "

if [ $REPLY == "production" ] || [ $REPLY == "staging" ]
then
    echo "Updating ES IP for the $REPLY environment"
else
    echo "Script STOPPED: Incorrect environment type!"
    exit 1
fi

ENV_TYPE=$REPLY

# Specify ES IP/Port
read -p "Provide the IP and port (IP:port) of the ES server: "

echo "$REPLY" > $CONFIG_DIR/$ENV_TYPE/ES_LOC

# Restart UWSGI for changes to take effect
systemctl restart opendal-$ENV_TYPE
