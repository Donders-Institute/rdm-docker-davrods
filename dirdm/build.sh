#!/bin/bash

if [ $# -ne 2 ]; then
    cat <<EOT

Usage:

    $ $0 <davrods_version> <irods_version>

For example, to build DavRods v1.1 against iRODS v4.1.8:

    $ $0 1.1 4.1.8

EOT

    exit 1
fi

v_davrods=$1
v_irods=$2
t_davrods=${v_davrods}

# it seems that the github tag (i.e. davrods version number) is not always consistent with
# the version number on the RPM file.
nf=$( echo ${v_davrods} | awk -F '.' '{print NF}' )
if [ $nf -eq 2 ]; then
    v_davrods=${v_davrods}.0
fi

docker build --force-rm -t davrods:${v_davrods} --build-arg irods_version=${v_irods} --build-arg davrods_github_tag=${t_davrods} --build-arg davrods_version=${v_davrods} ../davrods
