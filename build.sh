#!/bin/bash

dtap_env=$1

docker build --force-rm -t davrods:${dtap_env} --build-arg dtap_env=${dtap_env} .
