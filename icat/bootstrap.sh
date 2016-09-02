#!/bin/bash
RODS_PASSWORD=$1
RODS_SUDO_PASSWORD="demo123"

# generate configuration responses
/opt/irods/genresp.sh /opt/irods/setup_responses

if [ -n "$RODS_PASSWORD" ]; then
    RODS_SUDO_PASSWORD=$RODS_PASSWORD
    sed -i "14s/.*/$RODS_PASSWORD/" /opt/irods/setup_responses
    sed -i "s/^ACC_RODS_ADMIN_PASS = \".*\"/ACC_RODS_ADMIN_PASS = \"${RODS_SUDO_PASSWORD}\"/" /etc/irods/core.re
fi

# set up the iCAT database
service postgresql start
/opt/irods/setupdb.sh /opt/irods/setup_responses
# set up iRODS
/opt/irods/config.sh /opt/irods/setup_responses
#change irods user's irodsEnv file to point to localhost, since it was configured with a transient Docker container's $
#sed -i 's/^irodsHost.*/irodsHost localhost/' /var/lib/irods/.irods/.irodsEnv
sed -i 's/^.*"irods_host".*/    "irods_host": "localhost",/' /var/lib/irods/.irods/irods_environment.json

# set irods system account password for sudo
echo -e "${RODS_SUDO_PASSWORD}\n${RODS_SUDO_PASSWORD}" | (passwd irods)

# this script must end with a persistent foreground process
#tail -f /var/lib/irods/iRODS/server/log/rodsLog.*
sleep infinity
