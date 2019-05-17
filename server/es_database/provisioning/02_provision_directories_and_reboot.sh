#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Add persistent environment variables (available after restart)
cat config/environment_variables >> /etc/environment

# Make variables available in current terminal
set -a; source config/environment_variables; set +a;

#Create child directories
mkdir -p $CONFIG_DIR
mkdir -p $VENV_DIR
mkdir -p $TEMP_DIR
mkdir -p $REPO_DIR

# Create ES directories and chown them:
mkdir -p $CORE_DIR/elasticsearch/data
mkdir -p $CORE_DIR/elasticsearch/logs

chown -R elasticsearch:elasticsearch $CORE_DIR/elasticsearch/
chmod -R 771 $CORE_DIR/elasticsearch/

#Now reboot to set them
echo "Rebooting..."
reboot
