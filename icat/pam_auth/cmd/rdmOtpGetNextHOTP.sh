#!/bin/bash

sudo_pass=$1
user=$2

which oathtool > /dev/null 2>&1

if [ $? != 0 ]; then
    oathtool="/opt/oath-toolkit/bin/oathtool"
else
    oathtool="oathtool"
fi

# check if the user is already created in iRODS
iadmin lu | grep $user >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "iRODS account not found: $user" 1>&2
    exit 1
fi

# get OTP secret and count
otp_data=($( echo "$sudo_pass" | sudo -p '' -S bash -c "egrep -i '^HOTP/E\s+$user' /etc/irods/users.oath" ))

if [ $? -ne 0 ]; then
    echo "no OTP info for user: $user" 1>&2
    exit 2
fi

secret=${otp_data[3]}
count=-1
if [ ${#otp_data[@]} -gt 4 ]; then
    count=${otp_data[4]}
fi

# increment the count by 1
count=$( echo "1 + $count" | bc )

# get the next HOTP
otp=$( $oathtool -c $count $secret )

if [ $? -ne 0 ]; then
    echo "$oathtool returns non-zero exit code" 1>&2
    exit 3
else
    echo $otp
    exit 0
fi
