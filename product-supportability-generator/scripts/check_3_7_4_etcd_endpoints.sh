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
      echo -e "ETCD endpoint check: $master: [skipped] - reason: OpenShift ETCD seems to be not installed on this node, or not all data was collected"
   else
      # DIFF=$(diff pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_etcd_endpoints.out pssa-$master/var/tmp/pssa/tmp/*_etcd_endpoints.out)
      # diff <(cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_etcd_endpoints.out | awk -F "|" '{print $2,$3}') <(cat pssa-$master/var/tmp/pssa/tmp/*_etcd_endpoints.out | awk -F "|" '{print $2,$3}')
      DIFF=`diff <(awk -F "|" '{print $2,$3}' pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_etcd_endpoints.out) <(awk -F "|" '{print $2,$3}' pssa-$master/var/tmp/pssa/tmp/*_etcd_endpoints.out)`
      if [[ "$DIFF" = "" ]]  ; then
         echo -e "ETCD endpoint check: $master: ${GREEN}[passed]${NC} - reason: same endpoint list as reference node"      
      else
         echo -e "ETCD endpoint check:$master: ${YELLOW}[support limitation]${NC} - reason: all ETCD need to have the same endpoint list"
         echo "ETCD endpoint diff:"
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
   if [ ! -e pssa-$etcd/var/tmp/pssa/tmp/*_etcd_endpoints.out ] ; then
      echo -e "ETCD endpoint check: $etcd: [skipped] - reason: OpenShift ETCD seems to be not installed on this node, or not all data was collected"
   else
      # DIFF=$(diff pssa-${ETCDNODESARR[0]}/var/tmp/pssa/tmp/*_etcd_endpoints.out pssa-$master/var/tmp/pssa/tmp/*_etcd_endpoints.out)
      DIFF=`diff <(awk -F "|" '{print $2,$3}' pssa-${ETCDNODESARR[0]}/var/tmp/pssa/tmp/*_etcd_endpoints.out) <(awk -F "|" '{print $2,$3}' pssa-$etcd/var/tmp/pssa/tmp/*_etcd_endpoints.out)`
      if [[ "$DIFF" = "" ]]  ; then
         echo -e "ETCD endpoint check: $etcd: ${GREEN}[passed]${NC} - reason: same endpoint list as reference node"      
      else
         echo -e "ETCD endpoint check:$etcd: ${YELLOW}[support limitation]${NC} - reason: all ETCD need to have the same endpoint list"
         echo "ETCD endpoint diff:"
         echo "$DIFF"
      fi
   fi 
   done
fi
