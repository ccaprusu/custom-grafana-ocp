#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version

for master in $MASTERNODES
do
   if [ ! -e pssa-$master/var/tmp/pssa/tmp/*_etcd_health.out ] ; then
      echo -e "ETCD odd instance check: $master: [skipped] - reason: OpenShift ETCD seems to be not installed on this node, or not all data was collected"
   else
      MEMBERS=(`cat pssa-$master/var/tmp/pssa/tmp/*_etcd_member.out | grep "http" | awk '{print $2}'`)
      MEMBERS_STARTED=(`cat pssa-$master/var/tmp/pssa/tmp/*_etcd_member.out | grep "started" | awk '{print $2}'`)

      if (( ${#MEMBERS[@]} % 2 )); then
         echo -e "odd number of etcd: $master: ${GREEN}[passed]${NC} - reason: found ${#MEMBERS[@]} instances"
      else
         echo -e "odd number of etcd: $master: ${RED}[failed]${NC} - reason: found ${#MEMBERS[@]} instances"
      fi

      TEST=`echo "${#MEMBERS[@]} / 2" | bc`
      TEST=`echo "${#MEMBERS_STARTED[@]} > $TEST" | bc`
      if  [ ${TEST} -eq 1 ] ; then
         echo -e "majority of etcd started: $master: ${GREEN}[passed]${NC} - reason: found ${#MEMBERS_STARTED[@]} of ${#MEMBERS[@]} instances started"
      else
         echo -e "majority of etcd started: $master: ${RED}[failed]${NC} - reason: found ${#MEMBERS_STARTED[@]} of ${#MEMBERS[@]} instances started"
      fi
   fi
done
