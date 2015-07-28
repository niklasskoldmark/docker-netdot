#!/bin/sh
#################################################################
# Set variables
netdotpath="/usr/local/netdot"
configfile="$netdotpath/etc/Site.conf"

#################################################################
# Setup postfix
postconf -e relayhost="${POSTFIX_RELAY_PORT_25_TCP_ADDR:=$relayhost}"

#################################################################
# If /usr/local/netdot/etc/ is empty (mounted volume), copy the initial netdot configs
#[ ! "$(ls -A /usr/local/netdot/etc/ )" ] && cp -R $netdotpath/etcbck/* $netdotpath/etc/

# If /usr/local/netdot/etc/Site.conf doesnt exist (mounted volume), copy the initial Site.conf
[ ! -f /usr/local/netdot/etc/Site.conf ] && \
    cp $netdotpath/etcbck/Site.conf /usr/local/netdot/etc/Site.conf

# If /usr/local/netdot/etc/running_apache.conf (mounted volume), copy the initial running_apache.conf
[ ! -f /usr/local/netdot/etc/running_apache.conf ] && \
    cp $netdotpath/etcbck/netdot_apache24_local.conf /usr/local/netdot/etc/running_apache.conf

#################################################################
# If /usr/local/netdisco/mibs/ is empty (mounted volume), copy the initial mibs
[ ! "$(ls -A /usr/local/netdisco/mibs/ )" ] && \
cp -R /usr/local/netdisco/mibsbck/* /usr/local/netdisco/mibs/

#################################################################
# If /usr/local/netdot/export/cacti/ is empty (mounted volume), copy the initial cacti configs
[ ! "$(ls -A /usr/local/netdot/export/cacti/ )" ] && \
cp -R $netdotpath/export/cactibck/* $netdotpath/export/cacti/

#################################################################
# Fix access
chmod -R 777 /usr/local/netdisco/mibs/ && \
chmod -R 777 $netdotpath/etc/ && \
chmod -R 777 $netdotpath/export

#################################################################
# Fix /usr/local/netdot/etc/Site.conf
#################################################################
# Database setup
sed -i -e "s/^DB_TYPE\s.*/DB_TYPE => \'mysql\',/g" "$configfile"
sed -i -e "s/^DB_HOME\s.*/DB_HOME => \'\/usr\',/g" "$configfile"
sed -i -e "s/^DB_DBA\s.*/DB_DBA => \'root\',/g" "$configfile"
sed -i -e "s/^DB_DBA_PASSWORD\s.*/DB_DBA_PASSWORD => \'$MYSQL_ENV_MYSQL_ROOT_PASSWORD\',/g" "$configfile"
sed -i -e "s/^DB_HOST\s.*/DB_HOST => \'$MYSQL_PORT_3306_TCP_ADDR\',/g" "$configfile"
sed -i -e "s/^DB_PORT\s.*/DB_PORT => \'$MYSQL_PORT_3306_TCP_PORT\',/g" "$configfile"
# Set this to the canonical name of the interface NetDoT will be talking to the database on.
# If you said that the DB_HOST above was "localhost," this should be too.
# This value will be used to grant NetDoT access to the database.
# If you want to access the NetDoT database from multiple hosts, you'll need to grant those database rights by hand.
#DB_NETDOT_HOST =>  'localhost',
sed -i -e "s/^DB_NETDOT_HOST\s.*/DB_NETDOT_HOST => \'\%\',/g" "$configfile"
sed -i -e "s/^DB_DATABASE\s.*/DB_DATABASE => \'netdot\',/g" "$configfile"
sed -i -e "s/^DB_NETDOT_USER\s.*/DB_NETDOT_USER => \'netdot_user\',/g" "$configfile"
sed -i -e "s/^DB_NETDOT_PASS\s.*/DB_NETDOT_PASS => \'netdot_pass\',/g" "$configfile"
#####################################################################
# Contact stuff
sed -i -e "s/^SENDMAIL\s.*/SENDMAIL => \'\/usr\/sbin\/postfix\',/g" "$configfile"
#####################################################################
# SNMP specific
sed -i -e "s/^SNMP_MIBS_PATH\s.*/SNMP_MIBS_PATH => \'\/usr\/local\/netdisco\/mibs\',/g" "$configfile"
#####################################################################
# Device Management
sed -i -e "s/^POLL_STATS_FILE_PATH\s.*/POLL_STATS_FILE_PATH => \'\/var\/pollstats.rrd\',/g" "$configfile"
#####################################################################
# Misc
sed -i -e "s/^TMP\s.*/TMP => \"\/usr\/local\/netdot\/tmp\",/g" "$configfile"
sed -i -e "s/^NETDOT_PATH\s.*/NETDOT_PATH => \"\/usr\/local\/netdot\",/g" "$configfile"
#####################################################################
#  - NAGIOS - www.nagios.org
sed -i -e "s/^NAGIOS_DIR\s.*/NAGIOS_DIR => \'\/usr\/local\/netdot\/export\/nagios\',/g" "$configfile"
#####################################################################
#  - SYSMON - www.sysmon.org
sed -i -e "s/^SYSMON_DIR\s.*/SYSMON_DIR => \'\/usr\/local\/netdot\/export\/sysmon\',/g" "$configfile"
#####################################################################
#  - RANCID - http://www.shrubbery.net/rancid/
sed -i -e "s/^RANCID_DIR\s.*/RANCID_DIR => \'\/usr\/local\/netdot\/export\/rancid\',/g" "$configfile"
#####################################################################
#  - BIND - www.isc.org
sed -i -e "s/^BIND_EXPORT_DIR\s.*/BIND_EXPORT_DIR => \'\/usr\/local\/netdot\/export\/bind\',/g" "$configfile"
#####################################################################
#  - DHCPD - www.isc.org
sed -i -e "s/^DHCPD_EXPORT_DIR\s.*/DHCPD_EXPORT_DIR => \'\/usr\/local\/netdot\/export\/dhcpd\',/g" "$configfile"
#####################################################################
#  - Smokeping - http://oss.oetiker.ch/smokeping/
sed -i -e "s/^SMOKEPING_DIR\s.*/SMOKEPING_DIR => \'\/usr\/local\/netdot\/export\/smokeping\',/g" "$configfile"

#################################################################
# Wait for MYSQL server availability
while ! exec 6<>/dev/tcp/$MYSQL_PORT_3306_TCP_ADDR/$MYSQL_PORT_3306_TCP_PORT 
do
  echo "$(date) - still trying"
  sleep 1
done

#################################################################
# Install database if not done
configfile="etc/Site.conf"

if [ ! -f /srv/netdotdbinitdone ];
then
    cd /srv/netdot* && \
    sed -i -e "s/^DB_TYPE\s.*/DB_TYPE => \'mysql\',/g"  "$configfile" && \
    sed -i -e "s/^DB_HOME\s.*/DB_HOME => \'\/usr\',/g"  "$configfile" && \
    sed -i -e "s/^DB_DBA\s.*/DB_DBA => \'root\',/g"  "$configfile" && \
    sed -i -e "s/^DB_DBA_PASSWORD\s.*/DB_DBA_PASSWORD => \'$MYSQL_ENV_MYSQL_ROOT_PASSWORD\',/g"  "$configfile" && \
    sed -i -e "s/^DB_HOST\s.*/DB_HOST => \'$MYSQL_PORT_3306_TCP_ADDR\',/g"  "$configfile" && \
    sed -i -e "s/^DB_PORT\s.*/DB_PORT => \'$MYSQL_PORT_3306_TCP_PORT\',/g"  "$configfile" && \
    sed -i -e "s/^DB_NETDOT_HOST\s.*/DB_NETDOT_HOST => \'\%\',/g"  "$configfile" && \
    sed -i -e "s/^DB_DATABASE\s.*/DB_DATABASE => \'netdot\',/g"  "$configfile" && \
    sed -i -e "s/^DB_NETDOT_USER\s.*/DB_NETDOT_USER => \'netdot_user\',/g"  "$configfile" && \
    sed -i -e "s/^DB_NETDOT_PASS\s.*/DB_NETDOT_PASS => \'netdot_pass\',/g"  "$configfile" && \
    if [ -f bin/oui.txt ] ;
    then
        sed -i "/.*oui.txt.*/s/^/#/" bin/Makefile && \
        make installdb && \
        sed -i "/^#.*oui.txt.*/s/^#//" bin/Makefile
    else
    	make installdb
    fi  && \
    echo "GRANT ALL ON netdot.* TO netdot_user@'%' IDENTIFIED BY 'netdot_pass' WITH GRANT OPTION; FLUSH PRIVILEGES" | \
    mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h$MYSQL_PORT_3306_TCP_ADDR && \
    touch /srv/netdotdbinitdone
fi

#################################################################
# apache2
# If site is enabled, disable it (apache seems to crash otherwise)
a2dissite netdot.conf
# Start apache2
service apache2 start
# Enable the netdot.conf
a2ensite netdot.conf
# Reload apache2
service apache2 reload

#################################################################
# Watch directories for changes (exclude hidden directories), reload apache2 if changed
while : ; do
    inotifywait \
    --recursive \
    --timefmt '%d/%m/%y/%H:%M' \
    --format '%T %w%f' \
    --event modify \
    --event move \
    --event create \
    --exclude '/\..+' \
    /usr/local/netdisco/mibs/ \
    /usr/local/netdot/etc/running_apache.conf \
    /usr/local/netdot/etc/Site.conf \
    | while read time file; do
        if service apache2 reload
        then
            echo "${time} apache2 reloaded because change in ${file}" >> /srv/reloadconfig.log
            echo "${time} apache2 reloaded because change in ${file}"
        else
            a2dissite netdot.conf
            service apache2 start
            a2ensite netdot.conf
            service apache2 reload
            echo "${time} apache2 restarted because change in ${file}" >> /srv/reloadconfig.log
            echo "${time} apache2 restarted because change in ${file}"
        fi
    done
done