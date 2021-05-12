#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

MASTERNODEARR=($MASTERNODES)
ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $1}'`

IMAGE=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_images_in_use.out | grep 'descheduler' `

if [ ! -e pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_images_in_use.out ] ; then
     echo -e "Descheduler: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
else

   if [[ "$IMAGE" = "" ]]  ; then
      echo -e "Descheduler: ${GREEN}[passed]${NC} - reason: feature not enabled because no related image in use"   
   else
      if ( [[ $OCPMINOR -eq 11 ]] ); then
         echo -e "Descheduler: ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION Descheduler is in status \"Tech Preview\""
      else
         echo -e "Descheduler: ${RED}[failed]${NC} - reason: for OCP $OCPVERSION Descheduler is not supported"
      fi
      echo "Image details:"
      echo "$IMAGE"
   fi 
fi 
