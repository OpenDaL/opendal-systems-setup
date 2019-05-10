# Systems Provisioning for The Open Data Library (OpenDaL)
This repository contains the scripts and base configuration used for
initial installation and set-up of the OpenDaL servers.

## Architecture overview.
The architecture contains the following servers:

1. A web sever, running the Django front-end app (more [here](server/web/README.md))
2. A database sever, running the ES database for OpenDaL

The webserver is hosted behind CloudFlare, which takes care of server-client
SSL connections and allows for detailed configuration of website access.