#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "master-nodes"
for master in $MASTERNODES
do
   SUBS=` egrep 'OpenShift|SKU|Service Level|Service Type' pssa-$master/sosreport-*/sos_commands/subscription_manager/subscription-manager_list_--consumed`
   if [[ ! "$SUBS" =~ "OpenShift" ]] ; then
      echo -e "$master: [not applicable] ${YELLOW}WARNING: node not subscribed to RHSM or via Sat for any OpenShift SKU${NC}"
   else       
      if [[ ! "$SUBS" =~ "Broker/Master" ]] ; then
         echo -e "$master: [passed] - Note: for master-nodes \"Master/Broker Infrastructure\"-subs could get used."
      else
         echo -e "$master: ${GREEN}[passed]${NC}"
      fi
   fi
   echo "$SUBS"
done

echo "infra-nodes"
for infra in $INFRANODES
do
   SUBS=` egrep 'OpenShift|SKU|Service Level|Service Type' pssa-$infra/sosreport-*/sos_commands/subscription_manager/subscription-manager_list_--consumed`
   if [[ ! "$SUBS" =~ "OpenShift" ]] ; then
      echo -e "$infra: [not applicable] ${YELLOW}WARNING: node not subscribed to RHSM or via Sat for any OpenShift SKU${NC}"
   else       
      if [[ ! "$SUBS" =~ "Broker/Master" ]] ; then
         echo -e "$infra: ${GREEN}[passed]${NC} - ${BLUE}Note: for infra-nodes \"Master/Broker Infrastructure\"-subs could get used.${NC}"
      else
         echo -e "$infra: ${GREEN}[passed]${NC}"
      fi
   fi
   echo "$SUBS"
done

echo "application-nodes"
for node in $NODES
do
   SUBS=` egrep 'OpenShift|SKU|Service Level|Service Type' pssa-$node/sosreport-*/sos_commands/subscription_manager/subscription-manager_list_--consumed`
   if [[ ! "$SUBS" =~ "OpenShift" ]] ; then
      echo -e "$node: [not applicable] ${YELLOW}WARNING: node not subscribed to RHSM or via Sat for any OpenShift SKU${NC}"
   else       
      if [[ "$SUBS" =~ "Broker/Master" ]] ; then
         echo -e "$node: ${YELLOW}[support-limitation]${NC} - reason: \"Master/Broker Infrastructure\"-subs are not allowed to be used for compute-nodes."
      else
         echo -e "$node: ${GREEN}[passed]${NC}"
      fi
   fi
   echo "$SUBS"
done
