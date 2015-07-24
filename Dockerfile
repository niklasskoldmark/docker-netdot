FROM debian:8.1

MAINTAINER Niklas Skoldmark <niklas.skoldmark@gmail.com>

RUN apt-get update && apt-get install -y \
    apache2 \
    build-essential \
    graphviz \
    libapache-session-perl \
    libapache2-authcookie-perl \
    libapache2-mod-perl2 \
    libapache2-request-perl \
    libapache2-sitecontrol-perl \
    libauthen-radius-perl \
    libbind-config-parser-perl \
    libcarp-assert-perl \
    libcgi-pm-perl \
    libclass-dbi-abstractsearch-perl \
    libclass-dbi-perl \
    libcrypt-cast5-perl \
    libdbd-mysql-perl \
    libdigest-sha-perl \
    libfile-spec-perl \
    libgraphviz-perl \
    libhtml-mason-perl \
    liblog-dispatch-perl \
    liblog-log4perl-perl \
    libmodule-build-perl \
    libnet-appliance-session-perl \
    libnet-dns-perl \
    libnet-dns-zonefile-fast-perl \
    libnet-irr-perl \
    libnet-patricia-perl \
    libnetaddr-ip-perl \
    libparallel-forkmanager-perl \
    librrds-perl \
    libsnmp-info-perl \
    libsocket6-perl \
    libsql-translator-perl \
    libssl-dev \
    libtest-simple-perl \
    libtime-local-perl \
    liburi-perl \
    libxml-simple-perl \
    rrdtool \
    snmp

WORKDIR /srv

RUN wget http://se.archive.ubuntu.com/ubuntu/pool/multiverse/n/netdisco-mibs-installer/netdisco-mibs-installer_1.5_all.deb

RUN dpkg -i netdisco-mibs-installer_1.5_all.deb

RUN wget http://netdot.uoregon.edu/pub/dists/netdot-1.0.7.tar.gz

RUN tar xzvf netdot-1.0.7.tar.gz



EXPOSE 80
