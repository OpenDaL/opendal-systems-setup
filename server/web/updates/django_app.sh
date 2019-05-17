#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Pull newest code on active branch
git -C $REPO_DIR/datacatalog-frontend pull

# Restart UWSGI for changes to take effect
systemctl restart uwsgi
