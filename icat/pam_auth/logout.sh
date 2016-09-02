#!/bin/bash

irodsUserName=$1

if [ $# -ne 1 ]; then
    echo "usage: $0 <irodsUserName>" 1>&2
    exit 1
fi

imeta rmw -u $irodsUserName authToken %
