#!/usr/bin/python
#
# Read config file from env variable.
# Config file is a json like the following:
# 
# {
#   "node_ip": "10.0.0.10",
#   "cluster_ips": "10.0.0.10,10.0.0.11,10.0.0.12"
# }
# 
import os
import json
import subprocess

export_commands = []
config_file = os.getenv('CLUSTER_CONFIG')
if config_file:
  try:
    config = json.load(open(config_file))
    if config['node_ip']:
      export_commands.append('export NODE_IP='+config['node_ip'])
    if config['cluster_ips']:
      export_commands.append('export CLUSTER_IPS='+config['cluster_ips'])
  except Exception, e:
    pass
print "\n".join(export_commands)