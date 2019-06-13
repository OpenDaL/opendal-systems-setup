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

#Create child directories production
mkdir -p $WWW_DIR/production
mkdir -p $CONFIG_DIR/production
mkdir -p $LOGS_DIR/production
mkdir -p $VENV_DIR/production
mkdir -p $CODE_DIR/production

#Create child directories staging
mkdir -p $WWW_DIR/staging
mkdir -p $CONFIG_DIR/staging
mkdir -p $LOGS_DIR/staging
mkdir -p $VENV_DIR/staging
mkdir -p $CODE_DIR/staging

#Now reboot to set them
echo "Rebooting..."
reboot
