# ES Database server setup
The Database server hosts the ES database that contains the resource metadata
for the OpenDataLibrary.com platform. This database is rotated Weekly.

## Hardware
Currently, the database is hosted on a single Amazon t3.small instance, with
2 cores and 2GB of RAM. This is combined with an 8GB root volume (GP SSD) for
the software and OS, and a 48GB data volume (GP SSD) that contains the ES data
and logs.

## Server Installation and Rotation
Every week, after new data is harvested, a new database is created. This is
done, rather than updating the old database, to be able to easily transition
between the old and the new database. Because hardly any api supports
incremental harvesting of resource metadata, the dataset is completely
refreshed every week anyway.

To install (1) Create a new EC2 instance, (2) Copy the setup scripts to this
instance, (3) run the set-up scripts, (4) fill the new database,
(5) Configure the front-end to use the new database and (6) Terminate the old
database server

### 1 Create a new EC2 Instance:
Create a new instance on Amazon using the following steps:

1. Click 'Launch Instance' in the EC2 console, and select 'Ubuntu Server 18.04
LTS' (x86 variant).
2. Choose the 't3.medium' instance-type
3. Under _Instance Details_ select the same subnet as the web-server for
optimal latency, and deselect 'T2/T3 Unlimited' to control costs
4. In addition to the default 8GB root volume, add a new volume with 96GB of
storage (GP SSD type), and select 'delete on termination'
5. Add a 'Name' tag that indicates the week number (e.g.
_Database Server 201935_)
6. From Existing security groups, add FT Admin access (providing SSH and ES
access from the office) and Web Server ES Access (Provides ES access to web
server)
7. Launch the instance (Select the 'ES Database Server' key)

### 2 Copy setup scripts
1. Connect to the new server over SSH, and run
`mkdir -p ~/temp/opendal-systems-setup`.
2. In a new terminal tab, navigate to the root of this repo, and run
`./copy_to_server.sh`, and provide the IP of the server, and the location of
ESDatabaseServer.pem on your local machine

### 3 Run setup scripts
1. Return to the terminal tab with the SSH connection to the instance
2. `cd ~/temp/opendal-systems-setup/server/es_database/provisioning`
3. `sudo ./01_install_system_packages.sh`. Input the exact value of NAME for
the data volume of 96GB. For some updates it may ask to keep config files
which can be confirmed.
4. `sudo ./02_provision_directories_and_reboot.sh`
5. Wait for reboot (probably 1 to 2 minutes) and reconnect to the server
6. `cd ~/temp/opendal-systems-setup/server/es_database/provisioning`
7. `sudo ./03_configure_es.sh`.

ES should now start up. After half a minute, go to the browser to see if ES is
running on the public IP (e.g. http://236.223.12.1:9200/). You can use the
admin account credentials, to test whether it works. These credentials can be
found, along with the other credentials at `/home/ubuntu/es_creds.text`.

### 4 Fill the new database
You can fill the database with processed harvested data you have locally. This
is described in the readme of the ingestion-and-transformation repository.

Wait for this process to complete...

### 5 Configure the front-end to use the new database
See the heading 'Rotating the ES database' [here](../web/README.md)

### 6 Terminate the old database
Once you've made sure the production domains is successfully running on the new
database, stop the old database server in the AWS console. After it's stopped,
validate if OpenDataLibrary.com search functionality is still working. If this
is the case, terminate the old server
