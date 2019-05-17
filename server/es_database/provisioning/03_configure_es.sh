#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

set -e  # Make sure errors will stop execution

# Copy the JVM config, and generate the ES config
cp ../data/elasticsearch/jvm.options /etc/elasticsearch
chown root:elasticsearch /etc/elasticsearch/jvm.options

# Determine AWS instance metadata
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
local_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Use metadata to create elasticsearch config
rm -f /etc/elasticsearch/elasticsearch.yml
cat > /etc/elasticsearch/elasticsearch.yml <<- EOF
cluster.name: opendal-production
node.name: $instance_id
path.data: /data/elasticsearch/data
path.logs: /data/elasticsearch/logs
network.host: $local_ip
http.port: 9200
discovery.seed_hosts: []
cluster.initial_master_nodes: ["$instance_id"]
EOF
chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml

# All system settings, like process limits were set at package installation
# Start ES and enable service:
systemctl start elasticsearch
systemctl enable elasticsearch
