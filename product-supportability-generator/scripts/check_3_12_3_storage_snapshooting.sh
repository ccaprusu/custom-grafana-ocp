#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

MASTERNODEARR=($MASTERNODES)
ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $1}'`

STORAGECLASS=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_scs.out | grep 'volumesnapshot.external-storage.k8s.io/snapshot-promoter' -B4`

if [ ! -e pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_scs.out ] ; then
     echo -e "Storage snapshooting: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
else

if [[ "$STORAGECLASS" = "" ]]  ; then
   echo -e "Storage snapshooting: ${GREEN}[passed]${NC} - reason: feature not enabled on any storage class"   
else
   if ( [[ $OCPMINOR -lt 10 ]] ); then
      echo -e "Storage snapshooting: ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION Storage snapshooting is in status \"Tech Preview\""
   else
      echo -e "Storage snapshooting: ${GREEN}[passed]${NC}"
   fi
   echo "Storage class details:"
   echo "$STORAGECLASS"
fi 
fi 

   






