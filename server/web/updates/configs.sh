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
    echo "Updating config files for the $REPLY environment"
else
    echo "Script STOPPED: Incorrect environment type!"
    exit 1
fi

# Copy NGINX configs
cp ../data/nginx/opendal_$REPLY.conf /etc/nginx/sites-available
ln -sf /etc/nginx/sites-available/opendal_$REPLY.conf /etc/nginx/sites-enabled/

# Copy config dir
cp -r ../data/config/$REPLY/. $CONFIG_DIR/$REPLY

# Copy www dir
cp -r ../data/www/$REPLY/. $WWW_DIR/$REPLY

# Copy systemd dir
cp ../data/systemd/opendal-$REPLY.service /etc/systemd/system/

# Restart NGINX
systemctl daemon-reload
systemctl restart nginx
systemctl restart opendal-$REPLY
