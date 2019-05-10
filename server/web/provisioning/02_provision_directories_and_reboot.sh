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

# Create core directory
mkdir $CORE_DIR

# Create www directory
mkdir -p $CORE_DIR/www

#Create child directories
mkdir -p $CONFIG_DIR
mkdir -p $LOGS_DIR
mkdir -p $VENV_DIR
mkdir -p $TEMP_DIR
mkdir -p $REPO_DIR

#Now reboot to set them
echo "Rebooting..."
reboot
