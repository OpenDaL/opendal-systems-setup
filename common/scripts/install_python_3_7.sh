#!/bin/bash
set -e  # Make sure errors will stop execution

# The script assumes apt update has been run already
add-apt-repository -y ppa:deadsnakes/ppa
apt install -y python3.7
apt install -y python3.7-dev
apt install -y python3-venv #Required, otherwise venvs may not work with below package only
apt install -y python3.7-venv
