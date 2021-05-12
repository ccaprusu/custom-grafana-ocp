#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

number_of_nodes

TEST=`echo "${NUMBEROFETCD} <= 1" | bc`
if  [ ${TEST} -eq 1 ] ; then
echo "MASTER NODES"
for master in $MASTERNODES
do
   if [ ! -e pssa-$master/var/tmp/pssa/tmp/*_etcd_health.out ] ; then
      echo -e "ETCD health check: $master: [skipped] - reason: OpenShift ETCD seems to be not installed on this node, or not all data was collected"
   else
      UNHEALTHY=`cat pssa-$master/var/tmp/pssa/tmp/*_etcd_health.out | grep -v 'is healthy:'`
      if [[ "$UNHEALTHY" = "" ]]  ; then
         if [ -e pssa-$master/var/tmp/pssa/tmp/*_etcd_perf.out ] ; then
            PERF=`cat pssa-$master/var/tmp/pssa/tmp/*_etcd_perf.out | grep 'FAIL'`
            if [[ "$PERF" = "" ]]  ; then
               echo -e "ETCD health check: $master: ${GREEN}[passed]${NC} - reason: all collected etcd are healthy and performance check passed."
            else
               echo -e "ETCD health check: $master: ${YELLOW}[support limitation]${NC} - reason: all collected etcd are healthy, but performance check failed."
               PERF=`cat pssa-$master/var/tmp/pssa/tmp/*_etcd_perf.out | grep 'Throughput' -A2`
               echo "$PERF"
            fi
         else
            echo -e "ETCD health check: $master: ${GREEN}[passed]${NC} - reason: all collected etcd are healthy"   
         fi   
      else
         echo -e "ETCD health check:$master: ${YELLOW}[support limitation]${NC} - reason: all ETCD need to be in a healthy state"
         echo "ETCD details:"
         echo "$UNHEALTHY"
      fi
   fi
done
else
   if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
   fi
   for etcd in $ETCDNODES
   do
   if [ ! -e pssa-$etcd/var/tmp/pssa/tmp/*_etcd_health.out ] ; then
      echo -e "ETCD health check: $etcd: [skipped] - reason: OpenShift ETCD seems to be not installed on this node, or not all data was collected"
   else
      UNHEALTHY=`cat pssa-$etcd/var/tmp/pssa/tmp/*_etcd_health.out | grep -v 'is healthy:'`
      if [[ "$UNHEALTHY" = "" ]]  ; then
         echo -e "ETCD health check: $etcd: ${GREEN}[passed]${NC} - reason: all collected etcd are healthy"      
      else
         echo -e "ETCD health check: $etcd: ${YELLOW}[support limitation]${NC} - reason: all ETCD need to be in a healthy state"
         echo "ETCD details:"
         echo "$UNHEALTHY"
      fi
   fi
   done
fi
