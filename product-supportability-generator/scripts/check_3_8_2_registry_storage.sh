#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

MASTERNODEARR=($MASTERNODES)

VOLUME=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pvs.out | grep 'name:.*registry-' -A19 -B8`
FSTYPE=` echo "$VOLUME" | egrep "${ALL_FS_TYPES}" | sed -e 's/^ *//'`

if [[ "$VOLUME" = "" ]]  ; then
   echo -e "Registry storage type check: [not applicable] - reason: no registry PV found in configuration - check configuration"
else
   if ( [[ "$SUPPORTED_REGISTRY_FS_TYPES" =~ "$FSTYPE" ]] && [[ ! -z $FSTYPE ]] ); then
      echo -e "Registry storage type check: ${GREEN}[passed]${NC}"
   else
      PROVISONER=`echo "$VOLUME" | grep 'pv.kubernetes.io/provisioned-by:' | awk '{print $2}'`
      if [[ "$PROVISONER" = "" ]] ; then
         echo -e "Registry storage type check: ${RED}[failed]${NC} - reason: used fs-type $FSTYPE is not supported for registry"
      else
         echo -e "Registry storage type check: ${YELLOW}[support limitation]${NC} - reason: used fs-type $FSTYPE is not supported generally by Red Hat for registry, but might be supported via 3rd party $PROVISONER"
      fi
   fi

   ACCESSMODE=` echo "$VOLUME" | grep 'accessModes' -A1 `
   if [[ "$ACCESSMODE" =~ "ReadWriteMany" ]] ; then
      echo -e "Registry storage accessModes check: ${GREEN}[passed]${NC}"
   else
      echo -e "Registry storage accessModes check: ${RED}[failed]${NC} - reason: expected accessMode is \"ReadWriteMany\""
   fi

   RECLAIMPOLICY=` echo "$VOLUME" | grep 'persistentVolumeReclaimPolicy'`
   if [[ "$RECLAIMPOLICY" =~ "Retain" ]] ; then
      echo -e "Registry storage VolumeReclaimPolicy check: ${GREEN}[passed]${NC}"
   else
      echo -e "Registry storage VolumeReclaimPolicy check: ${RED}[failed]${NC} - reason: expected persistentVolumeReclaimPolicy is \"Retain\""
   fi

   max_pods_in_cluster
   STROAGEEXPECTED=` echo "${MAXPODCLUSTER} * 500 / 10000" | bc`
   FSSIZE=`echo "$VOLUME" | grep 'storage:' | awk '{print $2}' | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /\n/g'`
   FSSIZE=($FSSIZE)
   TEST=`echo "${FSSIZE[0]} < ${STROAGEEXPECTED}" | bc`
   if [ $TEST -eq 1 ] ; then
      echo -e "Registry storage sizing: ${YELLOW}[support limitation]${NC} - reason: configured storage of $FSSIZE GB seems to be small for a cluster capacity of $MAXPODCLUSTER pods - check storage considerations and pruning strategy"
   else
      echo -e "Registry storage sizing: ${GREEN}[passed]${NC} - reason: configured storage of $FSSIZE GB seems to be well sized for a cluster capacity of $MAXPODCLUSTER pods - but double check storage considerations and pruning strategy"
   fi
   echo "Registry PV details:"
   echo "$VOLUME"
fi
