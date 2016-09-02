#!/bin/bash

sudo_pass=$1
user=$2

# check if the user is already created in iRODS
iadmin lu | grep $user >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "iRODS account not found: $user" 1>&2
    exit 1
fi

# remove old key
echo "$sudo_pass" | sudo -S bash -c "sed -i '/HOTP\/E\t$user\t-/d' /etc/irods/users.oath" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    exit 2
fi

# insert new key for the user
s_key=$(head -c 1024 /dev/urandom | openssl sha1 |awk '{print $2}')
echo "$sudo_pass" | sudo -S bash -c "echo -e 'HOTP/E\t$user\t-\t$s_key' >> /etc/irods/users.oath" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    exit 0
else
    exit 1
fi
