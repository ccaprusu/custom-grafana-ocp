#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

MASTERNODEARR=($MASTERNODES)
ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $1}'`

CSIATTACHER=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_images_in_use.out | grep 'csi-attacher' `

if [ ! -e pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_images_in_use.out ] ; then
     echo -e "Storage CSI: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
else

   if [[ "$CSIATTACHER" = "" ]]  ; then
      echo -e "Storage CSI: ${GREEN}[passed]${NC} - reason: feature not enabled because no related image in use"   
   else
      if ( [[ $OCPMINOR -eq 11 ]] ); then
         echo -e "Storage CSI: ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION Storage CSI is in status \"Tech Preview\""
      else
         echo -e "Storage CSI: ${RED}[failed]${NC} - reason: for OCP $OCPVERSION Storage CSI is not supported"
      fi
      echo "Image details:"
      echo "$CSIATTACHER"
   fi 
fi 
