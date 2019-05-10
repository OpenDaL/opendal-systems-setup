#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Do initial update/upgrade
apt update
apt upgrade -y

# Install system package to add software repositories
apt install -y software-properties-common

# Install basic compilers
../../../common/scripts/install_compilers.sh

# Install python 3.7
../../../common/scripts/install_python_3_7.sh

# Install git
../../../common/scripts/install_git.sh

# Install nginx
../../../common/scripts/install_nginx.sh
