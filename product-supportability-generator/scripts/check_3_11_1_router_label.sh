#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`

MASTERNODEARR=($MASTERNODES)
INFRANODESARR=($INFRANODES)
CHECKFAILED=false

PODS=(`cat pssa-$MASTERNODEARR/var/tmp/pssa/tmp/*_all_pods.out | grep 'router-'`)

if [[ -z $PODS ]] ; then
     echo -e "Router Label check: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
   else

if ( [[ $OCPMINOR -lt 11 ]] ); then 
   ELEMEMTSPERLINE=9
else
   ELEMEMTSPERLINE=10
fi

PODNO=` echo " ${#PODS[@]} / $ELEMEMTSPERLINE" | bc`

for (( i=0; i<${#PODS[@]}; i=i+$ELEMEMTSPERLINE )); 
do
   PODHOSTNAME=${PODS[$i+7]}
   PODHOSTIP=${PODS[$i+6]}
   
   TEST=`cat pssa-$MASTERNODEARR/var/tmp/pssa/tmp/*_all_nodes.out  | grep "infra" | grep -E "$PODHOSTNAME|$PODHOSTIP"`
   if [[ "$TEST" = "" ]]  ; then
       NODEROLE=`cat pssa-$MASTERNODEARR/var/tmp/pssa/tmp/*_all_nodes.out | grep -E "$PODHOSTNAME|$PODHOSTIP" | awk '{print $3}'`
       echo -e "Router Label check: ${RED}[failed]${NC} - reason: $PODHOSTNAME nor $PODHOSTIP not found on an infra-node as expected, but has role \"$NODEROLE\""
       CHECKFAILED=true
   fi
done
if [[ $CHECKFAILED = false ]]  ; then
       echo -e "Router Label check: ${GREEN}[passed]${NC}"
fi

   echo "Router pod details:" 
   PODS=`cat pssa-$MASTERNODEARR/var/tmp/pssa/tmp/*_all_pods.out | grep 'router-'`
   echo "$PODS"
   echo "Infra-Nodes details:"
   for infra in $INFRANODES
   do
     HOSTNAME=`cat pssa-$infra/sosreport-*/etc/hostname`
     NODE=`cat pssa-$MASTERNODEARR/var/tmp/pssa/tmp/*_all_nodes.out | grep $HOSTNAME`
     echo "$NODE"
   done
fi
