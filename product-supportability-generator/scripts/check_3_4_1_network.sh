#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

number_of_nodes

CIDR=`cat pssa-${MASTERNODEARR[0]}/etc/origin/master/master-config.yaml | grep 'clusterNetworkCIDR' | awk -F ":" '{print $2}'`
if [[ $CIDR = "" ]] ; then
   NETWORKCONFIG=`cat pssa-${MASTERNODEARR[0]}/etc/origin/master/master-config.yaml | grep 'networkConfig' -A3`
   CIDR=`echo "$NETWORKCONFIG" | grep 'cidr' | awk -F ":" '{print $2}'`
fi

echo "MASTER NODES"

for master in $MASTERNODES
do
   IPROUTE=`cat pssa-$master/sosreport-*/sos_commands/networking/ip_route_show_table_all | grep ${CIDR}`
   if [[ $IPROUTE =~ "tun0" ]] ; then
      echo -e "Shared Network check: $master: ${GREEN}[passed]${NC}"
   elif [[ $IPROUTE =~ "tun" ]] ; then
      echo -e "Shared Manager check: $master: ${YELLOW}[support limitation]${NC} - reason: not tun0 in use on cluster network CIDR, what would be the default, so additional checks required."
   else
      echo -e "Shared Manager check: $master: ${RED}[failed]${NC} - reason: check details"
   fi

echo "ip route for cluster network CIDR: $IPROUTE"
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   IPROUTE=`cat pssa-$infra/sosreport-*/sos_commands/networking/ip_route_show_table_all | grep ${CIDR}`
   if [[ $IPROUTE =~ "tun0" ]] ; then
      echo -e "Shared Network check: $infra: ${GREEN}[passed]${NC}"
   elif [[ $IPROUTE =~ "tun" ]] ; then
      echo -e "Shared Manager check: $infra: ${YELLOW}[support limitation]${NC} - reason: not tun0 in use on cluster network CIDR, what would be the default, so additional checks required."
   else
      echo -e "Shared Manager check: $infra: ${RED}[failed]${NC} - reason: check details"
   fi

echo "ip route for cluster network CIDR: $IPROUTE"
done

echo "NODES"
for node in $NODES
do
   IPROUTE=`cat pssa-$node/sosreport-*/sos_commands/networking/ip_route_show_table_all | grep ${CIDR}`
   if [[ $IPROUTE =~ "tun0" ]] ; then
      echo -e "Shared Network check: $node: ${GREEN}[passed]${NC}"
   elif [[ $IPROUTE =~ "tun" ]] ; then
      echo -e "Shared Manager check: $node: ${YELLOW}[support limitation]${NC} - reason: not tun0 in use on cluster network CIDR, what would be the default, so additional checks required."
   else
      echo -e "Shared Manager check: $node: ${RED}[failed]${NC} - reason: check details"
   fi

echo "ip route for cluster network CIDR: $IPROUTE"
done
