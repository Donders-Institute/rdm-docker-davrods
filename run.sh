#!/bin/bash

dtap_env=$1
port=$2

docker run -p $port:443 --rm davrods:$dtap_env
