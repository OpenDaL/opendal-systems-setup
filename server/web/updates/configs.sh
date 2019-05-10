#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Copy NGINX configs
cp ../data/nginx/opendal_frontend.conf /etc/nginx/sites-available
ln -sf /etc/nginx/sites-available/opendal_frontend.conf /etc/nginx/sites-enabled/

# Copy config dir
cp ../data/config/* $CONFIG_DIR

# Copy www dir
cp ../data/www/* $CORE_DIR/www/

# Restart NGINX
systemctl restart nginx
systemctl restart uwsgi
