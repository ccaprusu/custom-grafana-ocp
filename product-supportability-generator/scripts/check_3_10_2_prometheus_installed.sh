#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`
MASTERNODEARR=($MASTERNODES)


REGISTRIES=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pods.out | grep 'prometheus'`

if [[ "$REGISTRIES" = "" ]]  ; then
   echo -e "Prometheus deployed: [not applicable] - reason: no related pods found"
else
   if ( [[ $OCPMINOR -lt 11 ]] ); then
      echo -e "Prometheus deployed: ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION Prometheus is in status \"Tech Preview\""
   else
      echo -e "Prometheus deployed: ${GREEN}[passed]${NC}"
   fi

   for master in $MASTERNODES
   do
      NODEEXPORTER=` cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pods.out | grep $master | grep 'node-exporter' `
      if [[ "$NODEEXPORTER" = "" ]]  ; then
          echo -e "Prometheus-Node-Exporter: $master ${RED}[failed]${NC} - reason: pod is missing"
      fi
   done

   for infra in $INFRANODES
   do
      NODEEXPORTER=` cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pods.out | grep $infra | grep 'node-exporter' `
      if [[ "$NODEEXPORTER" = "" ]]  ; then
          echo -e "Prometheus-Node-Exporter: $infra ${RED}[failed]${NC} - reason: pod is missing"
      fi
   done

   for nodes in $NODES
   do
      NODEEXPORTER=` cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_pods.out | grep $nodes | grep 'node-exporter' `
      if [[ "$NODEEXPORTER" = "" ]]  ; then
          echo -e "Prometheus-Node-Exporter: $nodes ${RED}[failed]${NC} - reason: pod is missing"
      fi
   done
   
   echo "Prometheus related pods:"
   echo "$REGISTRIES"
fi
