FROM ubuntu:14.04
MAINTAINER danb@renci.org

RUN apt-get update ; apt-get upgrade -y

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql wget libcurl4-gnutls-dev \
                                                      bc libpam-oath oathtool libpam-script
#install iRODS
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.1.9/ubuntu14/irods-database-plugin-postgres-1.9-ubuntu14-x86_64.deb -O /tmp/irods-dbplugin.deb
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.1.9/ubuntu14/irods-icat-4.1.9-ubuntu14-x86_64.deb -O /tmp/irods-icat.deb

# install package dependencies to prevent Docker build from erring out
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y `dpkg -I /tmp/irods-icat.deb | sed -n 's/^ Depends: //p' | sed 's/,//g'`
RUN dpkg -i /tmp/irods-icat.deb

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y `dpkg -I /tmp/irods-dbplugin.deb | sed -n 's/^ Depends: //p' | sed 's/,//g'`
RUN dpkg -i /tmp/irods-dbplugin.deb

RUN mkdir /opt/irods

ADD ./genresp.sh /opt/irods/genresp.sh
ADD ./setupdb.sh /opt/irods/setupdb.sh
ADD ./config.sh /opt/irods/config.sh
ADD ./bootstrap.sh /opt/irods/bootstrap.sh
RUN chmod a+x /opt/irods/*.sh

# setting up PAM
RUN mkdir /etc/irods/pam_script
RUN touch /etc/irods/users.oath

COPY ./pam_auth/irods /etc/pam.d/irods
COPY ./pam_auth/otp_cache /etc/irods/pam_script/pam_script_auth
COPY ./pam_auth/otp.re /etc/irods/otp.re
COPY ./pam_auth/server.key /etc/irods/server.key
COPY ./pam_auth/server.crt /etc/irods/chain.pem
COPY ./pam_auth/dhparams.pem /etc/irods/dhparams.pem
COPY ./pam_auth/setup_irods_environment.py /opt/irods/setup_irods_environment.py
COPY ./pam_auth/sudoers /etc/sudoers.d/irods
COPY ./pam_auth/cmd/*.sh /var/lib/irods/iRODS/server/bin/cmd/
COPY ./pam_auth/getUserNextHOTP.r /opt/irods/getUserNextHOTP.r

RUN chmod a+x /var/lib/irods/iRODS/server/bin/cmd/*.sh
RUN cp /etc/irods/core.re /etc/irods/core.re.org
RUN cat /etc/irods/otp.re /etc/irods/core.re.org > /etc/irods/core.re

RUN chmod 0444 /etc/irods/chain.pem /etc/irods/dhparams.pem
RUN chmod 0400 /etc/irods/server.key

ENV IRODS_SSL_CERT_CHAIN=/etc/irods/chain.pem
ENV IRODS_SSL_CERT_KEY=/etc/irods/server.key
ENV IRODS_SSL_DH_PARAMS=/etc/irods/dhparams.pem

EXPOSE 1247
#EXPOSE 1248
ENTRYPOINT [ "/opt/irods/bootstrap.sh" ]
