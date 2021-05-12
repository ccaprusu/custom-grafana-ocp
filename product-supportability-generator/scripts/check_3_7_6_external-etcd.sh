#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version

MASTERIPLIST=""

for master in $MASTERNODES
do
   if [ -e pssa-$master/sosreport-*/etc/origin/master/master-config.yaml ] ;then
      MASTERIP=`cat pssa-$master/sosreport-*/etc/origin/master/master-config.yaml| grep "masterIP" | awk -F ":" '{print $2}' | sed -r 's/\s+//g'`
   elif [ -e pssa-$master/etc/origin/master/master-config.yaml ] ;then
      MASTERIP=`cat pssa-$master/etc/origin/master/master-config.yaml| grep "masterIP" | awk -F ":" '{print $2}' | sed -r 's/\s+//g'`
   else
      echo -e "Master config check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi
   if [[ "$MASTERIPLIST" = "" ]]; then
      MASTERIPLIST=`echo "$MASTERIP"`
   else
      MASTERIPLIST=`echo "$MASTERIPLIST $MASTERIP"`
   fi
done

echo "$MASTERIPLIST"

ETCDMEMBERIPS=(`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_etcd_member.out | grep "http" | awk -F "|" '{print $5}'`)
ETCDMEMBERNAMES=(`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_etcd_member.out | grep "http" | awk -F "|" '{print $4}'`)

for (( i=0; i<${#ETCDMEMBERNAMES[@]}; i++ ));
do
   COLOCATED=false
   for masterip in $MASTERIPLIST
   do
      if [[ "${ETCDMEMBERIPS[i]}" =~ "$masterip" ]]; then
         COLOCATED=true
      fi
   done
   if [ $COLOCATED = true ]; then
      echo -e "colocated etcd: ${ETCDMEMBERNAMES[i]}: ${GREEN}[passed]${NC} - reason: is colocated"
   else
      if [[ ${OCPMINORVERSION} -gt 9 ]]; then
         echo -e "colocated etcd: ${ETCDMEMBERNAMES[i]}: ${YELLOW}[support limitation]${NC} - reason: is external"
         echo -e "${BLUE}Note: with OCP 3.10 and higher non-colocated ETCD is not a tested configuration by Red Hat and can lead to issues at any time.${NC}"
      else
         echo -e "colocated etcd: ${ETCDMEMBERNAMES[i]}: ${GREEN}[passed]${NC} - reason: for $OCPVERSION external ETCD is supported"
         echo -e "${BLUE}Note: with OCP 3.10 and higher non-colocated ETCD is not a tested configuration by Red Hat and can lead to issues at any time. Please considure colocating before upgrading.${NC}"
      fi 
   fi
done

