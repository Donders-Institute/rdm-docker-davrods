#!/bin/bash

sudo_pass=$1
user=$2

iadmin lu | grep $user > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "iRODS account not removed: $user" 1>&2
    exit 1
fi

# remove user entry 
echo "$sudo_pass" | sudo -S bash -c "sed -i '/HOTP\/E\t$user\t-/d' /etc/irods/users.oath" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "OTP secrete key deletion failure: $user" 1>&2
    exit 2
else
    exit 0
fi
