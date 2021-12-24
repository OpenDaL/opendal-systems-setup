# OpenDal Web Server setup
The Front-end code for OpenDataLibrary.com and test.OpenDataLibrary.com is run
on the web-server. The front-end Django code is run using UWSGI, as systemd
processes, and NGINX is used as the web facing server.

## Hardware
Currently, the webserver is hosted on a single Amazon t3.micro instance, with
2 cores and 1GB of RAM. This is combined with an 8GB root volume (GP SSD) for
the software, OS and front-end data.

## Server Installation and Rotation
Since updates of an in-place server can disrupt operation of
the OpenDataLibrary.com, updates are done every few weeks, by setting up a new
web-server.

To do this (1) Create a new EC2 instance, (2) Copy the setup scripts to this
instance, (3) run the set-up scripts (4) switch out public IP

### 1 Create a new EC2 Instance:
Create a new instance on Amazon using the following steps:

1. Click 'Launch Instance' in the EC2 console, and select 'Ubuntu Server 18.04
LTS' (x86 variant).
2. Choose the 't3.micro' instance-type
3. Under _Instance Details_ select the same subnet as the previous web-server
and Database server, for optimal latency, and deselect 'T2/T3 Unlimited' to
control costs
4. Use the default settings for the 8GB root volume
5. Add a 'Name' tag that indicates the week number (e.g. _Web Server 201935_)
6. Add Security groups that allow you, as admin, to access the server. Also,
   make sure that CloudFlare IP addresses are whitelisted if you wish to host
   the server behind CloudFlare.
7. Launch the instance

### 2 Copy setup scripts
1. Connect to the new server over SSH, and run
`mkdir -p ~/temp/opendal-systems-setup`.
2. In a new terminal tab, navigate to the root of this repo, and run
`./copy_to_server.sh`, and provide the IP of the server, and the location of
ESDatabase.pem on your local machine

### 3 Run setup scripts
1. Return to the terminal tab with the SSH connection to the instance
2. `cd ~/temp/opendal-systems-setup/server/web/provisioning`
3. `sudo ./01_install_system_packages.sh`
4. `sudo ./02_provision_directories_and_reboot.sh`
5. Wait for reboot (probably 1 to 2 minutes) and reconnect to the server
6. `cd ~/temp/opendal-systems-setup/server/es_database/provisioning`
7. `sudo ./03_install_django_app.sh`. This script asks for the _Django secret
key_, which is in the System Administrators Key vault, The _ES ip and port_ (
please make sure you provide the private IP of the ES server from the EC2
console, e.g. '172.16.226.32:9200'). The _ES Password_ for the ES server
'frontend' user can be found on that server at `/home/ubuntu/es_creds.txt`, if
it's installed using the scripts in this repository. After this it will open
the nano editor for _certificate.pem_ and _private.key_. For these files copy
the contents of the certificate files from the Key vault, paste it in nano
(ctrl+shift+v in terminal), do ctrl+x, type 'y' and press enter to save the
file. These files are the certificate and private key used by the server to
communicate with CloudFlare.
8. `sudo ./04_setup_uwsgi_services.sh`

Before testing, please make sure you've added the internal AWS IP of the new
machine (starting with 172.) to the 'Web Server ES Access' security group, so
the new web-server can access the database.

### 4 Switch out public IP
To also switch over the production domain:

1. Go to the EC2 console, select 'Elastic IPs' and re-associate the Elastic IP
of the old web server with the new one.
2. Browse the OpenDataLibrary.com website, and repeat step 5 above to validate
that indeed the new server is being used for your requests.
3. On the DNS page of CloudFlare, reset the IP of the test subdomain, to this
Elastic IP, and enable the page rule for the test domain.
4. On the server, over SSH, run `sudo systemctl stop opendal-staging` to stop
the staging UWSGI process

If everything is successful stop the old web server through the EC2 Console.
After stopping the old server, verify that opendatalibrary.com is still
working. If this is the case, terminate the old server.

## Server Maintenance

### Rotating the ES database
After you've created and filled the new database server, you can connect the
front-end to it. This is first tested on staging. SSH into the web server and:

1. `cd ~/temp/opendal-systems-setup/server/web/updates`
2. `sudo ./es_ip.sh`. This sets the new ES ip. As _environment_, input
'staging', as _ES IP_ input the __private IP__ of the new Database Server from
the EC2 Console, appended by ':9200' (the port number of the ES database). As
_ES Password_ input the password for the 'frontend' user, which can be found in
the file `/home/ubuntu/es_creds.txt` on the newly created ES Server.
1. Now test using 'test.opendatalibrary.com' to test if the new database
is used, sort results by 'modified' date, to see what the most recent modified
dates are.
4. If successful, update the dropdown-lists of the datacatalog-frontend repo,
as described in the README of that repo. Commit the updated repo to the
develop branch, and push it.
5. Run `sudo ./django_app.sh` in the SSH window, As _environment_, input
'staging', and provide the git credentials.
6. Put browser windows with test.opendatalibrary.com and opendatalibrary.com
alongside, and compare the counts in the selection box for the type field.
These should not be too different from each-other. Otherwise, this may indicate
that data is missing in the new database.
7. If all is good, run `sudo ./es_ip.sh`. This sets the new ES ip. As
_environment_, input 'production', as _ES IP_ input the same as used in
step (2)
8. On your local pc, checkout the master branch of the datacatalog-frontend
repo, and merge with develop. Push the repo. Again checkout develop afterwards
to reset for next time.
9. Run `sudo ./django_app.sh` in the SSH window, As _environment_, input
'production', and provide the git credentials.
10. Now test if the opendatalibrary.com main domain is completely functional. Sort
results by modified date, to make sure it's using the most recent database
server.
11. If all is good, disable the staging process
`sudo systemctl stop opendal-staging`, and enable the page-rule from step (3)
again