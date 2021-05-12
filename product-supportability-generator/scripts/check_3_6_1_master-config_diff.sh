#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

number_of_nodes

for master in $MASTERNODES
do
   echo "diff master-config.yaml ${MASTERNODEARR[0]} vs. $master" 
#   DIFF=$(diff pssa-${MASTERNODEARR[0]}/sosreport-*/etc/origin/master/master-config.yaml pssa-$master/sosreport-*/etc/origin/master/master-config.yaml)

   if [ -e pssa-$master/sosreport-*/etc/origin/master/master-config.yaml ] ;then
      DIFF=$(diff pssa-${MASTERNODEARR[0]}/sosreport-*/etc/origin/master/master-config.yaml pssa-$master/sosreport-*/etc/origin/master/master-config.yaml)
   elif [ -e pssa-$master/etc/origin/master/master-config.yaml ] ;then
      DIFF=$(diff pssa-${MASTERNODEARR[0]}/etc/origin/master/master-config.yaml pssa-$master/etc/origin/master/master-config.yaml)
   else
      echo -e "Master config check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   DIFF_CLEAN=`echo "$DIFF" | grep -v "masterIP:" `
   echo "$DIFF_CLEAN"
done
