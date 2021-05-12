#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

MASTERNODEARR=($MASTERNODES)
ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $1}'`

IMAGE=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pods.out | grep 'istio-operator' `

if [ ! -e pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pods.out ] ; then
     echo -e "Service Mesh: [skipped] - reason: OpenShift seems to be not installed on this node, or not all data was collected"
else

   if [[ "$IMAGE" = "" ]]  ; then
      echo -e "Service Mesh: ${GREEN}[passed]${NC} - reason: feature not enabled because no pod for istio-operator found"   
   else
      if ( [[ $OCPMINOR -eq 11 ]] ); then
         echo -e "Service Mesh: ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION Service Mesh is in status \"Tech Preview\""
      else
         echo -e "Service Mesh: ${RED}[failed]${NC} - reason: for OCP $OCPVERSION Service Mesh is not supported"
      fi
      echo "Image details:"
      echo "$IMAGE"
   fi 
fi 
