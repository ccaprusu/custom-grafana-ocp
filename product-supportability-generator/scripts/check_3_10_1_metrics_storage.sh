#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ListContains(){
  for test in $FSTYPE 
  do
     if ( [[ ! "$SUPPORTED_METRICS_FS_TYPES" =~ "$test" ]] ); then
        echo "1"
        return 1
     fi
  done
  echo "0"
  return 0
}

ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $1}'`
MASTERNODEARR=($MASTERNODES)


HAWKULAR=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pods.out | grep 'hawkular'`

if [[ "$HAWKULAR" = "" ]]  ; then
   echo -e "Hawkular-Metrics deployed: [not applicable] - reason: no related pods found"
else
   if ( [[ $OCPMINOR -gt 6 ]] ); then
      echo -e "Hawkular-Metrics deployed: ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION Hawkular-Metrics is in status \"Deprecated\""
   else
      echo -e "Hawkular-Metrics deployed: ${GREEN}[passed]${NC}"
   fi

   VOLUME=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pvs.out | grep 'metrics-' -A19 -B8`
   FSTYPE=` echo "$VOLUME" | egrep "${ALL_FS_TYPES}" | sed -e 's/^ *//'`

   if [[ "$VOLUME" = "" ]]  ; then
      echo -e "Hawkular-Metrics storage type check: [not applicable] - reason: no logging PV found in configuration"
   else
      #if ( [[ "$SUPPORTED_METRICS_FS_TYPES" =~ "$FSTYPE" ]] && [[ ! -z $FSTYPE ]] ); then
      CHECK=`ListContains $SUPPORTED_PROMETHEUS_FS_TYPES $FSTYPE`
      if ( [[ "$CHECK"  = "0" ]] ); then
         echo -e "Hawkular-Metrics storage type check: ${GREEN}[passed]${NC}"
      else
         PROVISONER=`echo "$VOLUME" | grep 'pv.kubernetes.io/provisioned-by:' | awk '{print $2}'`
      if ( [[ "$PROVISONER" = "" ]] || [[ "$PROVISONER" =~ "glusterfs" ]] ) ; then
         echo -e "Hawkular-Metrics storage type check: ${RED}[failed]${NC} - reason: used fs-type $FSTYPE is not supported for metrics, as block storage is recommended"
      else
         echo -e "Hawkular-Metrics storage type check: ${YELLOW}[support limitation]${NC} - reason: used fs-type $FSTYPE is not supported generally by Red Hat for metrics, but might be supported via 3rd party $PROVISONER"
      fi
      fi

      FSSIZE=` echo "$VOLUME" | grep 'storage:' | awk '{print $2}' | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | sed 's/ /\n/g'`
      max_pods_in_cluster
      MASTERNO=${#MASTERNODEARR[@]}
      INFRANODEARR=($INFRANODES)
      INFRANO=${#INFRANODEARR[@]}
      NODEARR=($NODES)
      NODENO=${#NODEARR[@]}
      TOTALNODENO=$(( $MASTERNO + $INFRANO + $NODENO ))
      NODESTORAGE=` echo "${TOTALNODENO} * ${METRICSTROAGE_PER_NODE}" | bc`
      PODSTORAGE=` echo "${MAXPODCLUSTER} * ${METRICSTROAGE_PER_POD}" | bc`
      STROAGEEXPECTED=` echo "${NODESTORAGE} + ${PODSTORAGE}" | bc`
      FSSIZE=($FSSIZE)
      TEST=`echo "${FSSIZE[0]} < ${STROAGEEXPECTED}" | bc`
      if  [ $TEST -eq 1 ] ; then
         echo -e "Hawkular-Metrics storage sizing: ${YELLOW}[support limitation]${NC} - reason: configured storage of ${FSSIZE[0]} GB is less than expected $STROAGEEXPECTED GB/week - check storage considerations"
      else
         echo -e "Hawkular-Metrics storage sizing: ${GREEN}[passed]${NC} - reason: configured storage of ${FSSIZE[0]} GB is more than expected $STROAGEEXPECTED GB/week "
      fi
      
      echo "Hawkular-Metrics PV details:"
      echo "$VOLUME"
   fi

fi
