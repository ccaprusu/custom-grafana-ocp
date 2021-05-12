#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
MASTERNODEARR=($MASTERNODES)

FAILEDONBLOCKVOLUMECOUNT=false

if [ ! -e pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*ocs.out ] ; then
   echo -e "ocs block volume count check: [skipped] - reason: seems \"pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*ocs.out\" is not available"
else
   BLOCKVOLUMES=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*ocs.out | grep 'number' | grep 'block' | awk -F ":" '{print $2}'`
   BLOCKVOLUMESARR=($BLOCKVOLUMES)
   for volumecount in "${BLOCKVOLUMESARR[@]}"
   do
      if [ ${volumecount} > 300 ] ; then
          FAILEDONBLOCKVOLUMECOUNT=true
      fi
   done

   if [ $FAILEDONBLOCKVOLUMECOUNT ] ; then
      echo -e "ocs block volume count check: ${GREEN}[passed]${NC} - reason: number of all found file volumes are below the limit of 300"
   else
      echo -e "ocs block volume count check: ${YELLOW}[support limitation]${NC} - reason: number of all found file volumes are above or equal the limit of 300"
   fi
fi
