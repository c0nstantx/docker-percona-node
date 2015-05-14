#!/bin/sh

# Start MySQL to create permissions
/usr/bin/mysqld_safe --no-defaults > /dev/null 2>&1 &
set +e
RET=1
while [ $RET -ne 0 ]; do
    echo "Waiting for MySQL to initialise..."
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

#mysql -e "SET wsrep_on=OFF; GRANT USAGE ON *.* TO 'haproxy'@'%';"
#mysql -e "SET wsrep_on=OFF; GRANT select ON *.* TO 'haproxy_check'@'%' IDENTIFIED BY '$MONITOR_PASS';"
mysql -e "CREATE USER '$REP_USER' IDENTIFIED BY '$REP_PASS';"
mysql -e "SET PASSWORD FOR '$REP_USER' = password('$REP_PASS');"
mysql -e "SET wsrep_on=OFF; GRANT ALL ON *.* TO '$REP_USER'@'%' IDENTIFIED BY '$REP_PASS';"
mysql -e "SET wsrep_on=OFF; GRANT ALL ON *.* TO '$REP_USER'@'localhost' IDENTIFIED BY '$REP_PASS';"
mysql -e "SET wsrep_on=OFF; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mysql -e "SET wsrep_on=OFF; GRANT SUPER ON *.* TO 'root'@'%' WITH GRANT OPTION;"
mysql -e 'FLUSH PRIVILEGES';
mysql -e "SET PASSWORD = password('$MYSQL_ROOT_PASSWORD');"

/usr/bin/mysqladmin -uroot -p$MYSQL_ROOT_PASSWORD shutdown > /dev/null 2>&1