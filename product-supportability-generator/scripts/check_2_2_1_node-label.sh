#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version

SCHEDULER_LABEL=`cat pssa-${MASTERNODEARR[0]}/etc/origin/master/scheduler.json | grep '"label":' | awk -F "\"" '{print $4}'`
SCHEDULER_LABELS=`cat pssa-${MASTERNODEARR[0]}/etc/origin/master/scheduler.json | grep '"labels":' -A3  | awk -F ":" '{print $1}' | egrep -v '"labels"|]|}'| sed 's/\"/ /g' | sed -e 's/ \+/ /g'`

SCHEDULER_LABEL_ARRAY=("$SCHEDULER_LABEL""$SCHEDULER_LABELS")

 echo -e "${BLUE}Note: this check is testing if all labels configured for the scheduler can be found on nodes. If the distribution makes sense and lead to a HA setup is to be checked manual${NC} "
echo "configured labels for scheduler: ${SCHEDULER_LABEL_ARRAY[@]}"

for label in $SCHEDULER_LABEL_ARRAY
do
   if [ ! "$label" = "" ]; then 
      NODES_WITH_LABEL=(`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*all_nodes.out | grep $label | awk '{print $1}'`)
#echo "found nodes: ${NODES_WITH_LABEL[@]}"
      if [ ${#NODES_WITH_LABEL[@]} -eq 0 ]; then
         echo -e "scheduler label on nodes: ${YELLOW}[HA Limitation]${NC} - reason: no nodes containing label \"$label\""
      else
         echo -e "scheduler label on nodes for label \"$label\": ${GREEN}[passed]${NC} - reason: label found on nodes:"
         for node in ${NODES_WITH_LABEL[@]}
         do
            LABELS4NODE=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*all_nodes.out | grep "$node " | awk '{print $11}' | sed 's/,/\n/g' | grep $label`
            echo "$node: $LABELS4NODE"
         done
      fi
   fi
done

for master in $MASTERNODES
do
 #  echo "diff scheduler.json ${MASTERNODEARR[0]} vs. $master" 

   if [ -e pssa-$master/etc/origin/master/scheduler.json ] ;then
      DIFF=$(diff pssa-${MASTERNODEARR[0]}/etc/origin/master/scheduler.json pssa-$master/etc/origin/master/scheduler.json)
   else
      echo -e "diff scheduler check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi
   if [ "$DIFF" = "" ]; then
      echo -e "diff scheduler check: $master: ${GREEN}[passed]${NC} - reason: no diff found"
   else
      echo -e "diff scheduler check: $master: ${RED}[failed]${NC} - reason: diff found:"
      echo "$DIFF"
   fi
done


