#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Clone git repo production (provide credentials through terminal...)
git clone https://gitlab.com/Tbro/datacatalog-frontend.git $CODE_DIR/production/datacatalog-frontend
# Replicate for staging
cp -r $CODE_DIR/production/datacatalog-frontend/ $CODE_DIR/staging/datacatalog-frontend/ # ONLY works because target directory does not exist yet
# For staging, checkout the develop branch
git -C $CODE_DIR/staging/datacatalog-frontend checkout develop

# Create a DJANGO secret key
read -p "Provide a Django SECRET_KEY: "
echo "$REPLY" > $CONFIG_DIR/production/DJANGO_SECRET_KEY
# Specify ES IP/Port
read -p "Provide the IP and port (IP:port) of the ES server: "
echo "$REPLY" > $CONFIG_DIR/production/ES_LOC
# Replicate config for staging
cp -r $CONFIG_DIR/production/. $CONFIG_DIR/staging


# Create production virtualenvs
python3.7 -m venv $VENV_DIR/production/opendal_frontend
python3.7 -m venv $VENV_DIR/staging/opendal_frontend

# Activate requirements for production venv
source $VENV_DIR/production/opendal_frontend/bin/activate
pip install wheel
pip install uwsgi
pip install -r $CODE_DIR/production/datacatalog-frontend/django/datacatalog/requirements.txt
export ENV_TYPE=production # Django uses this to determine the static dir
# Store default config dir variable, to reset after this
old_config_dir=$CONFIG_DIR
export CONFIG_DIR=$old_config_dir/production
python $CODE_DIR/production/datacatalog-frontend/django/datacatalog/manage.py collectstatic
deactivate

# Activate requirements for staging venv
source $VENV_DIR/staging/opendal_frontend/bin/activate
pip install wheel
pip install uwsgi
pip install -r $CODE_DIR/staging/datacatalog-frontend/django/datacatalog/requirements.txt
export ENV_TYPE=staging # Django uses this to determine the static dir
export CONFIG_DIR=$old_config_dir/production
python $CODE_DIR/staging/datacatalog-frontend/django/datacatalog/manage.py collectstatic
deactivate

# Restore config dir variable
export CONFIG_DIR=$old_config_dir

# Copy UWSGI configurations
cp ../data/config/production/uwsgi_opendal.ini $CONFIG_DIR/production
cp ../data/config/staging/uwsgi_opendal.ini $CONFIG_DIR/staging

# Copy robots.txt files
cp ../data/www/production/robots.txt $WWW_DIR/production
cp ../data/www/staging/robots.txt $WWW_DIR/staging

# Install nginx configurations for both environments
cp ../data/nginx/opendal_production.conf /etc/nginx/sites-available
cp ../data/nginx/opendal_staging.conf /etc/nginx/sites-available
rm /etc/nginx/sites-enabled/default
# Activate the NGINX configuration
ln -s /etc/nginx/sites-available/opendal_production.conf /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/opendal_staging.conf /etc/nginx/sites-enabled/

# Create certificate and private keys, can be provided through nano
mkdir -p $CORE_DIR/certs/opendatalibrary.com
nano $CORE_DIR/certs/opendatalibrary.com/certificate.pem
nano $CORE_DIR/certs/opendatalibrary.com/private.key

# Start NGINX
systemctl restart nginx
systemctl enable nginx
