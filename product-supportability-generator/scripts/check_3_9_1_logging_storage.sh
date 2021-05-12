#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ListContains(){
  for test in $FSTYPE 
  do
     if ( [[ ! "$SUPPORTED_LOGGING_FS_TYPES" =~ "$test" ]] ); then
        echo "1"
        return 1
     fi
  done
  echo "0"
  return 0
}

MASTERNODEARR=($MASTERNODES)

VOLUME=`cat pssa-${MASTERNODEARR[1]}/var/tmp/pssa/tmp/*_all_pvs.out | grep 'name:.*logging-' -A19 -B8`
FSTYPE=` echo "$VOLUME" | egrep "${ALL_FS_TYPES}" | sed -e 's/^ *//'`

if [[ "$VOLUME" = "" ]]  ; then
   echo -e "Logging storage type check: [not applicable] - reason: no logging PV found in configuration"
else
#   if ( [[ "$SUPPORTED_LOGGING_FS_TYPES" =~ "$FSTYPE" ]] && [[ ! -z $FSTYPE ]] ); then
   CHECK=`ListContains $SUPPORTED_LOGGING_FS_TYPES $FSTYPE`
   if ( [[ $CHECK  = 0 ]] ); then
      echo -e "Logging storage type check: ${GREEN}[passed]${NC}"
   else
      PROVISONER=`echo "$VOLUME" | grep 'pv.kubernetes.io/provisioned-by:' | awk '{print $2}'`
      if ( [[ "$PROVISONER" = "" ]] || [[ "$PROVISONER" =~ "glusterfs" ]] ) ; then
         echo -e "Logging storage type check: ${RED}[failed]${NC} - reason: used fs-type $FSTYPE is not supported for logging, as block storage is recommended"
      else
         echo -e "Logging storage type check: ${YELLOW}[support limitation]${NC} - reason: used fs-type $FSTYPE is not supported generally by Red Hat for logging, but might be supported via 3rd party $PROVISONER"
      fi
   fi

   max_pods_in_cluster
   STROAGEEXPECTED=` echo "${MAXPODCLUSTER} * ${LOGGING_BYTES_PER_SEC_PER_SEC} * 0.0864 /1000 * ${LOGGING_CURATOR_DEFAULT_DAYS}" | bc`
   FSSIZE=` echo "$VOLUME" | grep 'storage:' | awk '{print $2}' | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /\n/g'`
   FSSIZE=($FSSIZE)
   TEST=`echo "${FSSIZE[0]} < ${STROAGEEXPECTED}" | bc`
   if  [ $TEST -eq 1 ] ; then
      echo -e "Logging storage sizing: ${YELLOW}[support limitation]${NC} - reason: configured storage of ${FSSIZE[0]} GB is less than expected $STROAGEEXPECTED GB/30 days - check storage considerations"
   else
      TEST=`echo "${FSSIZE[0]} < ( 2 * ${STROAGEEXPECTED})" | bc`
      if  [ $TEST -eq 1 ] ; then
         echo -e "Logging storage sizing: ${YELLOW}[support limitation]${NC} - reason: configured storage of ${FSSIZE[0]} GB might get filled to much - check storage considerations"
      else
         echo -e "Logging storage sizing: ${GREEN}[passed]${NC} - reason: configured storage of ${FSSIZE[0]} GB is more than expected $STROAGEEXPECTED GB/30 days"
      fi
   fi
   echo "Logging PV details:"
   echo "$VOLUME"
fi

