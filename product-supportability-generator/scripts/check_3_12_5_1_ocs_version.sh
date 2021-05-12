#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
MASTERNODEARR=($MASTERNODES)

if [ ! -e pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*ocs.out ] ; then
   echo -e "ocs version check: [skipped] - reason: seems \"pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*ocs.out\" is not available"
else
   ocs_version
   if [[ "$OCSVERSION" = "" ]]  ; then
      echo -e "ocs version check: ${GREEN}[passed]${NC} - reason: no ocs related pods found"
   else
      if (( $OCSMINORVERSION <= ($OCPMINORVERSION + 1) && $OCSMINORVERSION >= ($OCPMINORVERSION - 1) )) ; then
         echo -e "ocs version check: ${GREEN}[passed]${NC} - reason: OCS version $OCSVERSION is supported with $OCPVERSION"
      else
         echo -e "ocs version check: ${YELLOW}[support limitation]${NC} - reason: OCS version $OCSVERSION is NOT supported with $OCPVERSION"
      fi
   fi
fi







