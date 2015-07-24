FROM debian:8.1

MAINTAINER Niklas Skoldmark <niklas.skoldmark@gmail.com>

RUN apt-get update && \
    apt-get install -y \
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
    snmp \
    mysql-client \
    curl

RUN cd /srv && \
    curl -L "http://downloads.sourceforge.net/project/netdisco/netdisco-mibs/latest-snapshot/netdisco-mibs-snapshot.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fnetdisco%2Ffiles%2Fnetdisco-mibs%2Flatest-snapshot%2F&ts=1393793276&use_mirror=heanet" |tar zxvf - && \
    mkdir -p /usr/local/netdisco/mibs/ && \
    cp -R /srv/netdisco-mibs/* /usr/local/netdisco/mibs/ && \
    echo 'deb http://ftp.se.debian.org/debian jessie main non-free' >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y snmp-mibs-downloader && \
    sed -i -e "s/mibs :.*/#mibs :/g" /etc/snmp/snmp.conf && \
    echo 'mibdirs +/usr/local/netdisco/mibs/' >> /usr/share/snmp/snmp.conf

RUN cd /srv && \
    curl -L "http://netdot.uoregon.edu/pub/dists/netdot-1.0.7.tar.gz" |tar zxvf - && \
    cd netdot* && \
    cp etc/Default.conf etc/Site.conf && \
    sed -i -e "s/SNMP_MIBS_PATH.*/SNMP_MIBS_PATH  => \'\/usr\/local\/netdisco\/mibs\',/g" etc/Site.conf && \
    sed -i -e "s/DEVICE_NAMING_METHOD_ORDER.*/DEVICE_NAMING_METHOD_ORDER  => [ \'sysname\', \'snmp_target\'],/g" etc/Site.conf && \
    make install APACHEUSER=www-data APACHEGROUP=www-data && \
    ln -s /usr/local/netdot/etc/netdot_apache24_local.conf /etc/apache2/sites-available/netdot_apache24_local.conf && \
    a2ensite netdot_apache24_local.conf

COPY ["setup.sh", "/setup.sh"]

COPY ["oui.txt", "/srv/netdot*/bin/"]

COPY ["entrypoint.sh", "/entrypoint.sh"]

CMD /setup.sh && rm /setup.sh

#ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
