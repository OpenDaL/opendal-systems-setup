#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Clone git repo (provide credentials through terminal...)
git clone https://gitlab.com/Tbro/datacatalog-frontend.git $REPO_DIR/datacatalog-frontend

# Create a DJANGO secret key
read -p "Provide a Django SECRET_KEY: "

echo "$REPLY" > $CONFIG_DIR/DJANGO_SECRET_KEY

# Specify ES IP/Port
read -p "Provide the IP and port (IP:port) of the ES server: "

echo "$REPLY" > $CONFIG_DIR/ES_LOC

# Create virtualenv and install requirements
python3.7 -m venv $VENV_DIR/opendal_frontend

# Activate venv and install requirements to it
source $VENV_DIR/opendal_frontend/bin/activate
pip install wheel
pip install uwsgi
pip install -r $REPO_DIR/datacatalog-frontend/django/datacatalog/requirements.txt
python $REPO_DIR/datacatalog-frontend/django/datacatalog/manage.py collectstatic
deactivate

# Copy Configurations
cp ../data/config/uwsgi_opendal.ini $CONFIG_DIR
cp ../data/nginx/opendal_frontend.conf /etc/nginx/sites-available
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/opendal_frontend.conf /etc/nginx/sites-enabled/

# Create certificate and private keys
mkdir -p $CORE_DIR/certs/beta.opendatalibrary.com
read -p "Provide beta.opendatalibrary.com certificate: "
echo "$REPLY" > $CORE_DIR/certs/beta.opendatalibrary.com/certificate.pem
read -p "Provide beta.opendatalibrary.com private key: "
echo "$REPLY" > $CORE_DIR/certs/beta.opendatalibrary.com/private.key

# Start NGINX
systemctl start nginx
systemctl enable nginx
