FROM centos:7

# install required packages
RUN ( yum -y install wget \
                     git zlib \
                     openssl openssl-libs \
                     boost boost-system boost-filesystem \
                     boost-chrono boost-regex boost-thread \
                     jansson fuse-libs \
                     httpd mod_ssl ca-certificates)

# create temporary directory
RUN ( mkdir -p /tmp )
WORKDIR /tmp

# install iRODS runtime and icommands
ARG irods_version=4.1.8
RUN ( wget ftp://ftp.renci.org/pub/irods/releases/$irods_version/centos7/irods-runtime-$irods_version-centos7-x86_64.rpm )
RUN ( rpm -ivh irods-runtime-$irods_version-centos7-x86_64.rpm )
RUN ( wget ftp://ftp.renci.org/pub/irods/releases/$irods_version/centos7/irods-icommands-$irods_version-centos7-x86_64.rpm )
RUN ( rpm -ivh irods-icommands-$irods_version-centos7-x86_64.rpm )

# install Davrods
ARG davrods_version=1.0.1
RUN ( wget https://github.com/UtrechtUniversity/davrods/releases/download/$davrods_version/davrods-$davrods_version-1.el7.centos.x86_64.rpm )
RUN ( rpm -ivh davrods-$davrods_version-1.el7.centos.x86_64.rpm )
RUN ( mv /etc/httpd/conf.d/davrods-vhost.conf /etc/httpd/conf.d/davrods-vhost.conf.org )

# cleanup RPMs
RUN ( yum clean all && rm -rf *.rpm )

# configure httpd for davrods
ARG dtap_env=acc
COPY $dtap_env/icat.pem /etc/httpd/irods/icat.pem
COPY $dtap_env/irods_environment.json /etc/httpd/irods/irods_environment.json
COPY $dtap_env/server.crt /etc/httpd/irods/server.crt
COPY $dtap_env/server.key /etc/httpd/irods/server.key
COPY $dtap_env/davrods-vhost.conf /etc/httpd/conf.d/davrods-vhost.conf

RUN ( chmod go+r /etc/httpd/irods/icat.pem )
RUN ( chmod go+r /etc/httpd/irods/irods_environment.json )
RUN ( chmod 0444 /etc/httpd/irods/server.crt )
RUN ( chmod 0400 /etc/httpd/irods/server.key )
RUN ( chmod go+r /etc/httpd/conf.d/davrods-vhost.conf )

# start httpd
COPY run-httpd.sh /opt/run-httpd.sh
RUN ( chmod +x /opt/run-httpd.sh )
EXPOSE 443
CMD ["/opt/run-httpd.sh"]
