#!/bin/bash
set -e  # Make sure errors will stop execution

# Create a DJANGO secret key
read -p "Provide the server IP Address: "
SVR_IP=$REPLY

read -p "Provide the key file location: "
KEY_FILE_LOC=$REPLY

scp -rp -i $KEY_FILE_LOC ./*  ubuntu@$SVR_IP:/home/ubuntu/temp/opendal-systems-setup
