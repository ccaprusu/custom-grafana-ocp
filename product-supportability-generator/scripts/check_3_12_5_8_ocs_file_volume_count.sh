#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
MASTERNODEARR=($MASTERNODES)

FAILEDONFILEVOLUMECOUNT=false

if [ ! -e pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*ocs.out ] ; then
   echo -e "ocs file volume count check: [skipped] - reason: seems \"pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*ocs.out\" is not available"
else
   FILEVOLUMES=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*ocs.out | grep 'number' | grep 'file' | awk -F ":" '{print $2}'`
   FILEVOLUMESARR=($FILEVOLUMES)
   BLOCKVOLUMES=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*ocs.out | grep 'number' | grep 'block' | awk -F ":" '{print $2}'`
   BLOCKVOLUMESARR=($BLOCKVOLUMES)
   i=0
   while [ $i -lt ${#FILEVOLUMESARR[@]} ];
   do
      if (( ( ${FILEVOLUMESARR[$i]} + ${BLOCKVOLUMESARR[$i]} ) > 1000 )) ; then
          FAILEDONFILEVOLUMECOUNT=true
      fi
      i=`expr $i + 1`
   done

   if [ $FAILEDONFILEVOLUMECOUNT ] ; then
      echo -e "ocs file volume count check: ${GREEN}[passed]${NC} - reason: number of all found file volumes are below the limit of 1000"
   else
      echo -e "ocs file volume count check: ${YELLOW}[support limitation]${NC} - reason: number of all found file volumes are above or equal the limit of 1000"
   fi
fi
