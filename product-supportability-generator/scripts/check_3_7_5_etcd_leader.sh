#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

number_of_nodes

TEST=`echo "${NUMBEROFETCD} <= 1" | bc`
if  [ ${TEST} -eq 1 ] ; then
echo "MASTER NODES"
for master in $MASTERNODES
do
   if [ ! -e pssa-$master/var/tmp/pssa/tmp/*_etcd_endpoints.out ] ; then
      echo -e "ETCD leader check: $master: [skipped] - reason: OpenShift ETCD seems to be not installed on this node, or not all data was collected"
   else
      REF_LEADER=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_etcd_endpoints.out | grep 'true' | awk -F "|" '{print $2,$3}'`
      LEADER=`cat  pssa-$master/var/tmp/pssa/tmp/*_etcd_endpoints.out | grep 'true' | awk -F "|" '{print $2,$3}'`
      if [[ "$LEADER" = "$REF_LEADER" ]]  ; then
         echo -e "ETCD leader check: $master: ${GREEN}[passed]${NC} - reason: same leader as reference node"      
      else
         echo -e "ETCD leader check:$master: ${YELLOW}[support limitation]${NC} - reason: all ETCD need to have the same leader"
         echo "ETCD leader diff:"
         echo "$LEADER"
      fi
   fi
done
else
   if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
   fi
   for etcd in $ETCDNODES
   do
      if [ ! -e pssa-$etcd/var/tmp/pssa/tmp/*_etcd_endpoints.out ] ; then
         echo -e "ETCD leader check: $etcd: [skipped] - reason: OpenShift ETCD seems to be not installed on this node, or not all data was collected"
      else
         REF_LEADER=`cat pssa-${ETCDNODESARR[0]}/var/tmp/pssa/tmp/*_etcd_endpoints.out | grep 'true'`
         LEADER=`cat  pssa-$etcd/var/tmp/pssa/tmp/*_etcd_endpoints.out | grep 'true'`
         if [[ "$LEADER" = "$REF_LEADER" ]]  ; then
            echo -e "ETCD leader check: $etcd: ${GREEN}[passed]${NC} - reason: same leader as reference node"      
         else
            echo -e "ETCD leader check:$etcd: ${YELLOW}[support limitation]${NC} - reason: all ETCD need to have the same leader"
            echo "ETCD leader diff:"
            echo "$LEADER"
         fi
      fi
   done
fi
