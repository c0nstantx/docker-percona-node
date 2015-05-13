#!/bin/sh

if [ -z "$NODE_IP" ]; then
	NODE_IP=$(/bin/ip -4 a show dev eth0 scope global | grep inet | awk '{split($2,a,"/"); print a[1]}')
fi
WSREP_OPTIONS="--wsrep_node_address=$NODE_IP --wsrep_sst_receive_address=$NODE_IP --wsrep_sst_auth=$REP_USER:$REP_PASS --wsrep_node_name=$NODE_NAME --wsrep_cluster_name=$CLUSTER_NAME $DB_OPTIONS"

OPTIONS="--port=$MYSQL_PORT --wsrep_cluster_address=gcomm://"
if [ ! -z "$CLUSTER_IPS" ]; then
   OPTIONS="$OPTIONS$CLUSTER_IPS"
fi

if [ $BOOTSTRAP_CLUSTER -eq 1 ]; then
  echo "Bootstraping Cluster..."
  OPTIONS="$OPTIONS --wsrep-new-cluster"
fi

trap "/usr/bin/mysqladmin shutdown" 0
trap 'exit 2' 1 2 3 15

if [ ! -d ${DATA_DIR:-/var/lib/mysql}/mysql ]; then
  mysql_install_db > /dev/null 2>&1
else
  chown -R mysql:mysql ${DATA_DIR:-/var/lib/mysql}
fi

/mysql-init.sh &
# echo "mysqld_safe $OPTIONS $WSREP_OPTIONS"
exec mysqld_safe $OPTIONS $WSREP_OPTIONS & wait