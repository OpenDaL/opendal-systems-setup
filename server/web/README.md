# OpenDal Web Server setup
The web server runs the front-end of the OpenDataLibrary. The front-end code is
created with Django, which is run using UWSGI on the server. NGINX is used as
the web facing server.

## Server Creation
For the Web facing server, a t3.micro AWS instance is used (2 cores, 1GB RAM).
AWS firewall groups for this server are:

1. Admin Access: Provide access from the IP of the admin for SSH and showing
the website (port 443)
2. CloudFlare HTTPS: Provide access for all CloudFlare IP ranges to access the
HTTPS port (443) on the server. The CloudFlare IP ranges can be found here:
https://www.cloudflare.com/ips/

## Installation Steps
Running the scripts from the 'provisioning' directory in the order indicated by
the numbers in the filenames, will take care of the initial system setup. After
these steps the webserver will be running.

At some points these scripts require user input to:

* Authenticate GIT requests
* Provide a Django SECRET_KEY for production
* Provide the Certificate and Private key file contents. For this you'll need
the Origin Certificate generated in the CloudFlare Admin Interface

After server installation, make sure to set the correct server IP Address in
the CloudFlare DNS configuration.

## Updating
Using the scripts in the 'updates' directory, several parts of the system can
be updated.
