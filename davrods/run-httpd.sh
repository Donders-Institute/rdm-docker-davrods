#!/bin/bash

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/* /tmp/httpd*

# settle files for running the service
if [ -f /config/icat.pem ]; then
    cp /config/icat.pem /etc/httpd/irods/icat.pem
    chmod 0644 /etc/httpd/irods/icat.pem
fi

if [ -f /config/davrods-vhost.conf ]; then
    if [ -f /etc/httpd/conf.d/davrods-vhost.conf ]; then
        cp /etc/httpd/conf.d/davrods-vhost.conf /etc/httpd/conf.d/davrods-vhost.conf.org
    fi
    cp /config/davrods-vhost.conf /etc/httpd/conf.d/davrods-vhost.conf
    chmod 0644 /etc/httpd/conf.d/davrods-vhost.conf
fi

if [ -f /config/irods_environment.json ]; then
    cp /config/irods_environment.json /etc/httpd/irods/irods_environment.json
    chmod 0644 /etc/httpd/irods/irods_environment.json
fi

if [ -f /config/server.crt ]; then
    cp /config/server.crt /etc/httpd/irods/server.crt
    chmod 0444 /etc/httpd/irods/server.crt
fi

if [ -f /config/server.key ]; then
    cp /config/server.key /etc/httpd/irods/server.key
    chmod 0400 /etc/httpd/irods/server.key
fi

if [ -f /config/server-ca-chain.crt ]; then
    cp /config/server-ca-chain.crt /etc/httpd/irods/server-ca-chain.crt
    chmod 0444 /etc/httpd/irods/server-ca-chain.crt
fi

# start the apache daemon
exec /usr/sbin/apachectl -DFOREGROUND
