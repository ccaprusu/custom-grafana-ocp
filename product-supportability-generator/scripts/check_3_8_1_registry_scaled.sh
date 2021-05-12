#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

MASTERNODEARR=($MASTERNODES)

REGISTRIES=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pods.out | grep 'docker-registry-'`

if [[ "$REGISTRIES" = "" ]]  ; then
   echo -e "Registry scaled: [not applicable] - reason: no related pods found - check configuration"
else
   REGISTRIESARR=($REGISTRIES)
   REGISTRIESPODS=` echo " ${#REGISTRIESARR[@]} / 9" | bc`
   if  [ $REGISTRIESPODS -gt 1 ] ; then
       echo -e "Registry scaled check: ${GREEN}[passed]${NC} - reason: found $REGISTRIESPODS registry pods - check supported storage carefully as scaled"
   else
       echo -e "Registry scaled check: ${GREEN}[passed]${NC} - reason: found $REGISTRIESPODS registry pods"
   fi
   echo "Registry related pods:"
   echo "$REGISTRIES"
fi
