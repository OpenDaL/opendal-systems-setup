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

# Specify password (autogenerated for a new server)
read -s -p "Provide the Password for the 'frontend' ES user: "
echo # By default it doesn't go to the next line
echo "$REPLY" > $CONFIG_DIR/$ENV_TYPE/ES_PASS

# Restart UWSGI for changes to take effect
systemctl restart opendal-$ENV_TYPE
