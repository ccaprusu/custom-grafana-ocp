#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

MASTERNODEARR=($MASTERNODES)
ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $1}'`

IMAGE=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_images_in_use.out | grep 'node-problem-detector' `

if [ ! -e pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_images_in_use.out ] ; then
     echo -e "Node Problem Detector: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
else

   if [[ "$IMAGE" = "" ]]  ; then
      echo -e "Node Problem Detector: ${GREEN}[passed]${NC} - reason: feature not enabled because no related image in use"   
   else
      if ( [[ $OCPMINOR -eq 11 ]] ); then
         echo -e "Node Problem Detector: ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION Node Problem Detector is in status \"Tech Preview\""
      else
         echo -e "Node Problem Detector: ${RED}[failed]${NC} - reason: for OCP $OCPVERSION Node Problem Detector is not supported"
      fi
      echo "Image details:"
      echo "$IMAGE"
   fi 
fi 
