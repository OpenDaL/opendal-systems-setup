#!/bin/bash
set -e  # Make sure errors will stop execution

# The script assumes apt update has been run already
add-apt-repository ppa:deadsnakes/ppa
apt install -y python3.7
apt install -y python3.7-dev
apt install -y python3.7-venv