#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

NETWORKPLUGIN_EXPECTED=""
WARNING=""

for master in $MASTERNODES
do
   EPHEMERAL_STORAGE=`cat pssa-$master/etc/origin/master/master-config.yaml | grep 'LocalStorageCapacityIsolation'`
   
   if [[ ! -e pssa-$master/etc/origin/master/master-config.yaml  ]] ; then
     echo -e "$master: Ephemeral Storage [skipped] - reason: OpenShift seems to be not installed on this node"
   else
      if [[ $EPHEMERAL_STORAGE =~ "true" ]]; then
         if ( [[ $OCPMINOR -eq 11 ]] ); then
            echo -e "$master: Ephemeral Storage ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION Ephemeral Storage is in status \"Tech Preview\""
         else
            echo -e "$master: Ephemeral Storage ${RED}[failed]${NC} - reason: for OCP $OCPVERSION Ephemeral Storage is not supported"
         fi
      else
          echo -e "$master: ${GREEN}[passed]${NC}"
      fi
      echo "master-config details:"
      echo "$EPHEMERAL_STORAGE"
   fi
done
