#!/bin/bash

# Start MySQL to create Percona XtraDB Cluster UDFs (User Defined Function) from Percona Toolkit
/usr/bin/mysqld_safe > /dev/null 2>&1 &
set +e
RET=1
while [ $RET -ne 0 ]; do
	echo "Waiting for MySQL to initialise..."
	sleep 5
	mysql -uroot -e "status" > /dev/null 2>&1
	RET=$?
done

mysql -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
mysql -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
mysql -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

mysqladmin -uroot shutdown