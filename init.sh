#!/bin/bash

function create-sistearth-user {
	mysql --user=root --password=$MYSQL_PASSWORD --execute="CREATE USER sistearth@localhost IDENTIFIED BY '${SISTEARTH_PASSWORD}';"
	mysql --user=root --password=$MYSQL_PASSWORD --execute="GRANT ALL PRIVILEGES ON *.* TO sistearth@localhost;"
}

/usr/bin/mysqld_safe & 
sleep 10s
MYSQL_PASSWORD=`pwgen -c -n -1 12`
echo "mysql root password: $MYSQL_PASSWORD"
echo "mysql root password: $MYSQL_PASSWORD" >> /passwords
mysqladmin -u root password $MYSQL_PASSWORD 


SISTEARTH_PASSWORD=`pwgen -c -n -1 12`
echo "sistearth password: $SISTEARTH_PASSWORD"
echo "sistearth password (user and mysql): $SISTEARTH_PASSWORD" >> /passwords
create-sistearth-user
echo "sistearth:${SISTEARTH_PASSWORD}" | chpasswd

killall mysqld
sleep 10s
