#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

DNS_EXPECTED=""

for master in $MASTERNODES
do
   DNS=`cat pssa-$master/sosreport-*/etc/dnsmasq.d/origin-upstream-dns.conf | sort`

   if [[ -z $DNS_EXPECTED ]] ;then
      DNS_EXPECTED=$DNS
      echo "configured DNS servers:"
      echo "$DNS_EXPECTED"
      DNS_ARR=($DNS_EXPECTED)
      if [ ${#DNS_ARR[*]} -lt 2 ] ; then
         echo -e "${BLUE}Note: found ${#DNS_ARR[*]} name-servers configured. Recommended is to have at least 2.${NC}"
      fi
      echo "MASTER NODES"
   fi

   if [[ -z $DNS ]] ; then
     echo -e "$master: [skipped] - reason: OpenShift seems to be not installed on this node"
   else
   if [ "$DNS" = "$DNS_EXPECTED" ] ; then
      echo -e "$master: ${GREEN}[passed]${NC}"
   else
      echo -e "$master: ${RED}[failed]${NC} - found: $DNS"
   fi 
   fi

done

echo "INFRA NODES"
for infra in $INFRANODES
do
   DNS=`cat pssa-$infra/sosreport-*/etc/dnsmasq.d/origin-upstream-dns.conf | sort`
   if [[ -z $DNS ]] ; then
     echo -e "$infra: [skipped] - reason: OpenShift seems to be not installed on this node"
   else
   if [ "$DNS" = "$DNS_EXPECTED" ] ; then
      echo -e "$infra: ${GREEN}[passed]${NC}"
   else
      echo -e "$infra: ${RED}[failed]${NC} - found: $DNS"
   fi 
   fi
done

echo "NODES"
for node in $NODES
do
   DNS=`cat pssa-$node/sosreport-*/etc/dnsmasq.d/origin-upstream-dns.conf | sort`
   if [[ -z $DNS ]] ; then
     echo -e "$node: [skipped] - reason: OpenShift seems to be not installed on this node"
   else
   if [ "$DNS" = "$DNS_EXPECTED" ] ; then
      echo -e "$node: ${GREEN}[passed]${NC}"
   else
      echo -e "$node: ${RED}[failed]${NC} - found: $DNS"
   fi 
   fi
done
