#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

MASTERNODEARR=($MASTERNODES)
ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $1}'`

OLM=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_images_in_use.out | grep 'operator-lifecycle-manager' `

if [ ! -e pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_images_in_use.out ] ; then
     echo -e "Operator Lifecycle Manager: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
else

   if [[ "$OLM" = "" ]]  ; then
      echo -e "Operator Lifecycle Manager: ${GREEN}[passed]${NC} - reason: feature not enabled because no related image in use"   
   else
      if ( [[ $OCPMINOR -eq 11 ]] ); then
         echo -e "Operator Lifecycle Manager: ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION Operator Lifecycle Manager is in status \"Tech Preview\""
      else
         echo -e "Operator Lifecycle Manager: ${RED}[failed]${NC} - reason: for OCP $OCPVERSION Operator Lifecycle Manager is not supported"
      fi
      echo "Image details:"
      echo "$OLM"
   fi 
fi 
