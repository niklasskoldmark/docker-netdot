#!/bin/sh

while ! exec 6<>/dev/tcp/$DB_PORT_3306_TCP_ADDR/$DB_PORT_3306_TCP_PORT 
do
  echo "$(date) - still trying"
  sleep 1
done

cd /srv/netdot*
sed -i -e "s/^DB_DBA_PASSWORD.*/DB_DBA_PASSWORD  => \'$MYSQL_ENV_MYSQL_ROOT_PASSWORD',/g" etc/Site.conf
sed -i -e "s/^DB_HOST.*/DB_HOST  => \'$MYSQL_PORT_3306_TCP_ADDR\',/g" etc/Site.conf
sed -i -e "s/^DB_PORT.*/DB_PORT  => \'$MYSQL_PORT_3306_TCP_PORT\',/g" etc/Site.conf
sed -i -e "s/^DB_NETDOT_HOST.*/DB_NETDOT_HOST  => \'%\',/g" etc/Site.conf

make installdb
echo "GRANT ALL ON netdot.* TO netdot_user@'%' IDENTIFIED BY 'netdot_pass' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql -uadmin -h$DB_PORT_3306_TCP_ADDR -pmysql-server
touch /netdotinitdone

sed -i -e "s/^DB_DBA_PASSWORD.*/DB_DBA_PASSWORD  => \'$MYSQL_ENV_MYSQL_ROOT_PASSWORD',/g" /usr/local/netdot/etc/Site.conf
sed -i -e "s/^DB_HOST.*/DB_HOST  => \'$MYSQL_PORT_3306_TCP_ADDR\',/g" /usr/local/netdot/etc/Site.conf
sed -i -e "s/^DB_PORT.*/DB_PORT  => \'$MYSQL_PORT_3306_TCP_PORT\',/g" /usr/local/netdot/etc/Site.conf
sed -i -e "s/^DB_NETDOT_HOST.*/DB_NETDOT_HOST  => \'%\',/g" /usr/local/netdot/etc/Site.conf

service apache2 start
