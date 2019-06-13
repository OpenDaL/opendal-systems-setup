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
    echo "Updating django app for the $REPLY environment"
else
    echo "Script STOPPED: Incorrect environment type!"
    exit 1
fi

# Pull newest code on active branch
git -C $CODE_DIR/$REPLY/datacatalog-frontend pull

# Update the static files on the machine
source $VENV_DIR/$REPLY/opendal_frontend/bin/activate
export ENV_TYPE=$REPLY # Used by django in collectstatic script
old_config_dir=$CONFIG_DIR
export CONFIG_DIR=$old_config_dir/$REPLY
python $CODE_DIR/$REPLY/datacatalog-frontend/django/datacatalog/manage.py collectstatic
deactivate

# Restart UWSGI for changes to take effect
systemctl restart opendal-$REPLY
