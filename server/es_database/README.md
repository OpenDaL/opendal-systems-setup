### ES Database server provisioning
To provision the ES Database Server, create the following on AWS:

    1. Create an AWS server t3.medium with 8GB root and 96GB EBS
    2. Set subnet to correct zone (same as web server)
    3. change T2/T3 Unlimited to disable
    4. Add security policies to access the server as an admin (always define
        your ip) and to grant the web server access at port 9200 using its
        internal IP

After setting this, copy this repository to the server using the
copy_to_server.sh in the root of the repostory, and run the scripts in the
provisioning directory in the numbered order.

After this ES will be running on the server
