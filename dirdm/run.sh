#!/bin/bash

if [ $# -ne 3 ]; then
    cat <<EOT

Usage:

    $ $0 <davrods_version> <abspath_to_config> <service_port_host>

where the <abspath_to_config> is the directory in which all necessary configuration files are provided, while <service_port_host> is the host's service port mapped to the port 443 exported by the container.

For example:

    $ $0 1.1 `pwd`/config 443

EOT

  exit 1
fi

v_davrods=$1
config_dir=$2
port=$3

# it seems that the github tag (i.e. davrods version number) is not always consistent with
# the version number on the RPM file.
nf=$( echo ${v_davrods} | awk -F '.' '{print NF}' )
if [ $nf -eq 2 ]; then
    v_davrods=${v_davrods}.0
fi

docker run -v ${config_dir}:/config -p ${port}:443 -d davrods:${v_davrods}
