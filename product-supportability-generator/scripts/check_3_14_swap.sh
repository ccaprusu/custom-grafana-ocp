#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "MASTER NODES"
for master in $MASTERNODES
do
   SWAPCONFIG=`cat pssa-$master/sosreport-*/proc/swaps | awk '{print $6}'`

   if [[ $SWAPCONFIG = "" ]] ; then
      echo -e "Swap check: $master: ${GREEN}[passed]${NC}"
   else
      echo -e "Swap check: $master: ${YELLOW}[support limitation]${NC} - reason: swap is recommended to be disabled as it interfear with cgroups-limits"
      echo "Swap config:"
      SWAPCONFIG=`cat pssa-$master/sosreport-*/proc/swaps`
      echo "$SWAPCONFIG"
   fi 
done

if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
fi

for etcd in $ETCDNODES
do
   SWAPCONFIG=`cat pssa-$etcd/sosreport-*/proc/swaps | awk '{print $6}'`

   if [[ $SWAPCONFIG = "" ]] ; then
      echo -e "Swap check: $etcd: ${GREEN}[passed]${NC}"
   else
      echo -e "Swap check: $etcd: ${YELLOW}[support limitation]${NC} - reason: swap is recommended to be disabled as it interfear with cgroups-limits"
      echo "Swap config:"
      SWAPCONFIG=`cat pssa-$etcd/sosreport-*/proc/swaps`
      echo "$SWAPCONFIG"
   fi 
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   SWAPCONFIG=`cat pssa-$infra/sosreport-*/proc/swaps | awk '{print $6}'`

   if [[ $SWAPCONFIG = "" ]] ; then
      echo -e "Swap check: $infra: ${GREEN}[passed]${NC}"
   else
      echo -e "Swap check: $infra: ${YELLOW}[support limitation]${NC} - reason: swap is recommended to be disabled as it interfear with cgroups-limits"
      echo "Swap config:"
      SWAPCONFIG=`cat pssa-$infra/sosreport-*/proc/swaps`
      echo "$SWAPCONFIG"
   fi 
done

echo "NODES"
for node in $NODES
do
   SWAPCONFIG=`cat pssa-$node/sosreport-*/proc/swaps | awk '{print $6}'`

   if [[ $SWAPCONFIG = "" ]] ; then
      echo -e "Swap check: $node: ${GREEN}[passed]${NC}"
   else
      echo -e "Swap check: $node: ${YELLOW}[support limitation]${NC} - reason: swap is recommended to be disabled as it interfear with cgroups-limits"
      echo "Swap config:"
      SWAPCONFIG=`cat pssa-$node/sosreport-*/proc/swaps`
      echo "$SWAPCONFIG"
   fi 
done
