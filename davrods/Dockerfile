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
ARG davrods_github_tag=$davrods_version
RUN ( wget https://github.com/UtrechtUniversity/davrods/releases/download/$davrods_github_tag/davrods-$davrods_version-1.el7.centos.x86_64.rpm )
RUN ( rpm -ivh davrods-$davrods_version-1.el7.centos.x86_64.rpm )
RUN ( mv /etc/httpd/conf.d/davrods-vhost.conf /etc/httpd/conf.d/davrods-vhost.conf.org )

# cleanup RPMs
RUN ( yum clean all && rm -rf *.rpm )

# mountable volumes for necessary configuration files
# the executable 'run-httpd.sh' expects the following files to be provided
# and will move them into proper locations before starting the HTTPd searvice
#
# The expected files:
#   - davrods-vhost.conf: the Apache configuration for the WebDAV vhost
#   - icat.pem: the public key for DavRods to connect to iCAT over SSL
#   - irods_environment.json: runtime environment of iRODS
#   - server.crt: certificate of the HTTPd/WebDAV service
#   - server.key: private key of the HTTPd/WebDAV service
#   - server-ca-chain.crt: chain of certificates used to sign the server.crt (not needed for self-signed certificate)
VOLUME [ "/config" ]

# start httpd
COPY run-httpd.sh /opt/run-httpd.sh
RUN ( chmod +x /opt/run-httpd.sh )
EXPOSE 443
CMD ["/opt/run-httpd.sh"]
