#!/bin/sh

`/export_env.py`
# If node IP is not defined as env variable, get it from system
if [ -z "$NODE_IP" ]; then
	NODE_IP=$(/bin/ip -4 a show dev eth0 scope global | grep inet | awk '{split($2,a,"/"); print a[1]}')
fi
WSREP_OPTIONS="--wsrep_node_address=$NODE_IP --wsrep_sst_receive_address=$NODE_IP --wsrep_sst_auth=$REP_USER:$REP_PASS --wsrep_node_name=$NODE_NAME --wsrep_cluster_name=$CLUSTER_NAME $DB_OPTIONS"

OPTIONS="--port=$MYSQL_PORT"

if [ ! -d ${DATA_DIR:-/var/lib/mysql}/mysql ]; then
  mysql_install_db > /dev/null 2>&1
  if [ $BOOTSTRAP_CLUSTER -eq 1 ]; then
      /mysql-init.sh
  fi
else
  chown -R mysql:mysql ${DATA_DIR:-/var/lib/mysql}
fi

if [ $BOOTSTRAP_CLUSTER -eq 1 ]; then
  echo "Bootstraping Cluster..."
  OPTIONS="$OPTIONS --wsrep-new-cluster --wsrep_cluster_address=gcomm://"
else
    if [ ! -z "$CLUSTER_IPS" ]; then
       OPTIONS="$OPTIONS  --wsrep_cluster_address=gcomm://$CLUSTER_IPS"
    fi
fi

mysqld_safe $OPTIONS $WSREP_OPTIONS