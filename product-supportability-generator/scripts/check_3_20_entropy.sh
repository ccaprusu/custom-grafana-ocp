#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "MASTER NODES"
for master in $MASTERNODES
do
   ENTROPY=`cat pssa-$master/sosreport-*/proc/sys/kernel/random/entropy_avail`

   if [[ $ENTROPY -gt 800 ]] ; then
      echo -e "Available Entropy check: $master: ${GREEN}[passed]${NC}"
   else
      echo -e "Available Entropy check: $master: ${YELLOW}[support limitation]${NC} - reason: available entropy is recommended to be larger than 800"
      echo "Available Entropy: $ENTROPY"
   fi 
done


echo "INFRA NODES"
for infra in $INFRANODES
do
   ENTROPY=`cat pssa-$infra/sosreport-*/proc/sys/kernel/random/entropy_avail`

   if [[ $ENTROPY -gt 800 ]] ; then
      echo -e "Available Entropy check: $infra: ${GREEN}[passed]${NC}"
   else
      echo -e "Available Entropy check: $infra: ${YELLOW}[support limitation]${NC} - reason: available entropy is recommended to be larger than 800"
      echo "Available Entropy: $ENTROPY"
   fi 
done

echo "NODES"
for node in $NODES
do
   ENTROPY=`cat pssa-$node/sosreport-*/proc/sys/kernel/random/entropy_avail`

   if [[ $ENTROPY -gt 800 ]] ; then
      echo -e "Available Entropy check: $node: ${GREEN}[passed]${NC}"
   else
      echo -e "Available Entropy check: $node: ${YELLOW}[support limitation]${NC} - reason: available entropy is recommended to be larger than 800"
      echo "Available Entropy: $ENTROPY"
   fi 
done
