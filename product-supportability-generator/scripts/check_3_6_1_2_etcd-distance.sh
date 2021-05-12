#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

number_of_nodes

for master in $MASTERNODES
do
   if [ -e pssa-$master/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      NODENAME=`cat pssa-$master/sosreport-*/etc/origin/node/node-config.yaml | grep "nodeName" | awk -F ":" '{print $2}' | sed -r 's/\s+//g'`
   elif [ -e pssa-$master/etc/origin/node/node-config.yaml ] ;then
      NODENAME=`cat pssa-$master/etc/origin/node/node-config.yaml | grep "nodeName" | awk -F ":" '{print $2}' | sed -r 's/\s+//g'`
   elif [ -e pssa-$master/tmp/node-config.yaml ] ;then
      NODENAME=`cat pssa-$master/tmp/node-config.yaml | grep "nodeName" | awk -F ":" '{print $2}' | sed -r 's/\s+//g'`
  elif [ -e pssa-$master/node-config.yaml ] ;then
      NODENAME=`cat pssa-$master/node-config.yaml | grep "nodeName" | awk -F ":" '{print $2}' | sed -r 's/\s+//g'`
   else
      echo -e "Node config check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ "$NODENAME" = "" ]]; then
      NODENAME=`echo "$master"`
   fi

   if [ -e pssa-$master/sosreport-*/etc/origin/master/master-config.yaml ] ;then
      NEARESTETCD=`cat pssa-$master/sosreport-*/etc/origin/master/master-config.yaml | grep "etcdClientInfo" -A10  | grep "urls" -A1`
   elif [ -e pssa-$master/etc/origin/master/master-config.yaml ] ;then
      NEARESTETCD=`cat pssa-$master/etc/origin/master/master-config.yaml | grep "etcdClientInfo" -A10  | grep "urls" -A1`
   else
      echo -e "Master config check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ "$NEARESTETCD" =~ "$NODENAME" ]]; then
      echo -e "$master: ${GREEN}[passed]${NC} - reason: master-API on will connect preferred to local ETCD"
   else
      echo -e "$master: ${YELLOW}[support limitation]${NC} - reason: this master-API will connect preferred to remote ETCD"
      echo -e "${BLUE}Note: to get the best load distribution on ETCD every master-API should connect to the nearest ETCD, what in case of colocated is the local${NC}"
       if [ -e pssa-$master/sosreport-*/etc/origin/master/master-config.yaml ] ;then
          ETCDLIST=`cat pssa-$master/sosreport-*/etc/origin/master/master-config.yaml | grep "etcdClientInfo" -A10  | grep "urls" -A3`
       else
          ETCDLIST=`cat pssa-$master/etc/origin/master/master-config.yaml | grep "etcdClientInfo" -A10  | grep "urls" -A3`
       fi
       echo "$ETCDLIST"
   fi
done
