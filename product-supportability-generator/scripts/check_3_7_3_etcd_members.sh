#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

number_of_nodes

TEST=`echo "${NUMBEROFETCD} <= 1" | bc`
if  [ ${TEST} -eq 1 ] ; then
echo "MASTER NODES"
for master in $MASTERNODES
do  
   if [ ! -e pssa-$master/var/tmp/pssa/tmp/*_etcd_member.out ] ; then
      echo -e "ETCD member check: $master: [skipped] - reason: OpenShift ETCD seems to be not installed on this node, or not all data was collected"
   else
      DIFF=$(diff pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_etcd_member.out pssa-$master/var/tmp/pssa/tmp/*_etcd_member.out)
      if [[ "$DIFF" = "" ]]  ; then
         echo -e "ETCD diff check: $master: ${GREEN}[passed]${NC} - reason: same member list as reference node"      
      else
         echo -e "ETCD diff check:$master: ${YELLOW}[support limitation]${NC} - reason: all ETCD need to have same member list"
         echo "ETCD member diff:"
         echo "$DIFF"
      fi
   fi
done
else
   if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
   fi
   for etcd in $ETCDNODES
   do
      if [ ! -e pssa-$etcd/var/tmp/pssa/tmp/*_etcd_member.out ] ; then
      echo -e "ETCD member check: $etcd: [skipped] - reason: OpenShift ETCD seems to be not installed on this node, or not all data was collected"
   else
      DIFF=$(diff pssa-${ETCDNODESARR[0]}/var/tmp/pssa/tmp/*_etcd_member.out pssa-$etcd/var/tmp/pssa/tmp/*_etcd_member.out)
      if [[ "$DIFF" = "" ]]  ; then
         echo -e "ETCD diff check: $etcd: ${GREEN}[passed]${NC} - reason: same member list as reference node"      
      else
         echo -e "ETCD diff check:$etcd: ${YELLOW}[support limitation]${NC} - reason: all ETCD need to have same member list"
         echo "ETCD member diff:"
         echo "$DIFF"
      fi
   fi
   done
fi
