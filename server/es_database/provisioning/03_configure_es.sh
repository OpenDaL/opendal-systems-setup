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
network.host: [127.0.0.1, $local_ip]
http.port: 9200
discovery.type: single-node
xpack.security.enabled: true
EOF
chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml
# All system settings, like process limits were set at package installation

# Generate random passwords:
temp_pass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
data_upload_pass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
frontend_pass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
elastic_pass=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)

# Bootstrap password needs to be set, in order to configure other accounts through API:
echo $temp_pass | /usr/share/elasticsearch/bin/elasticsearch-keystore add --stdin bootstrap.password

# Start ES and enable service:
systemctl start elasticsearch
systemctl enable elasticsearch

# Now wait for ES to come online
response_code=$(curl -I -u elastic:$temp_pass -s "http://localhost:9200/" -o /dev/null -w "%{http_code}\n" || true)
while [ $response_code != "200" ]
do
    echo "Waiting 5 more seconds for ES to initialize..."
    sleep 5
    response_code=$(curl -I -u elastic:$temp_pass -s "http://localhost:9200/" -o /dev/null -w "%{http_code}\n" || true)
done

# Create new accounts for the frond-end and upload script to connect through
curl --silent --user elastic:$temp_pass -H "Content-Type: application/json" -X PUT -d "{\"password\": \"$data_upload_pass\",\"roles\": [ \"superuser\" ]}" http://localhost:9200/_security/user/data_upload
curl --silent --user elastic:$temp_pass -H "Content-Type: application/json" -X PUT -d "{\"password\": \"$frontend_pass\",\"roles\": [ \"superuser\" ]}" http://localhost:9200/_security/user/frontend

# Edit elastic user to get rid of bootstrapped password. This is the admin user
curl --silent --user elastic:$temp_pass -H "Content-Type: application/json" -X POST -d "{\"password\":\"$elastic_pass\"}" http://localhost:9200/_security/user/elastic/_password

# Write the relevant passwords to home folder, for later reference
cat > /home/ubuntu/es_creds.txt <<- EOF
Upload script credentials:
username: data_upload
password: $data_upload_pass

Frontend credentials:
username: frontend
password: $frontend_pass

Admin user:
username: elastic
password: $elastic_pass
EOF
echo # Empty line, to seperate from curl output
echo "ES Setup completed!"
echo "To show the ES user credentials, do 'cat /home/ubuntu/es_creds.txt'"