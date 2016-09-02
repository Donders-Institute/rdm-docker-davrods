#!/bin/bash

sudo_pass=$1
user=$2

# check if the user is already created in iRODS
iadmin lu | grep $user >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "iRODS account not found: $user" 1>&2
    exit 1
fi

# check if the user has already TOTPSharedSecretKey metadata in place
echo "$sudo_pass" | sudo -S bash -c "egrep '^HOTP/E\s+$user\s+-' /etc/irods/users.oath" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "OTP secrete key already presented: $user" 1>&2
    exit 2
fi

# generate OTP secrete key and add it to the user's metadata 
s_key=$(head -c 1024 /dev/urandom | openssl sha1 |awk '{print $2}')
echo "$sudo_pass" | sudo -S bash -c "echo -e 'HOTP/E\t$user\t-\t$s_key' >> /etc/irods/users.oath" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    exit 0
else
    echo "OTP secrete key creation failure: $user" 1>&2
    exit 2
fi
