#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "MASTER NODES"

for master in $MASTERNODES
do
   NM=`$CITELLUS_BASE/citellus.py -v -d WARNING -i network-manager-enabled  pssa-$master/sosreport-*/ | grep network | sed 's/^.*\(plugins.*\).*$/\1/'`
   NMSTATUS=`echo "$NM" | grep 'network-manager-enabled' | awk -F ":" '{print $2}'`

   if [[ $NMSTATUS =~ "okay" ]] ; then
      echo -e "Network-Manager check: $master: ${GREEN}[passed]${NC}"
   else
      echo -e "Network-Manager check: $master: ${RED}[failed]${NC} - reason: check details"
   fi
   echo "Network-Manager details:"
   echo "$NM"
done

if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
fi

for etcd in $ETCDNODES
do
   NM=`$CITELLUS_BASE/citellus.py -v -d WARNING -i network-manager-enabled  pssa-$etcd/sosreport-*/ | grep network | sed 's/^.*\(plugins.*\).*$/\1/'`
   NMSTATUS=`echo "$NM" | grep 'network-manager-enabled' | awk -F ":" '{print $2}'`

   if [[ $NMSTATUS =~ "okay" ]] ; then
      echo -e "Network-Manager check: $etcd: ${GREEN}[passed]${NC}"
   else
      echo -e "Network-Manager check: $etcd: ${RED}[failed]${NC} - reason: check details"
   fi
   echo "Network-Manager details:"
   echo "$NM"
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   NM=`$CITELLUS_BASE/citellus.py -v -d WARNING -i network-manager-enabled  pssa-$infra/sosreport-*/ | grep network | sed 's/^.*\(plugins.*\).*$/\1/'`
   NMSTATUS=`echo "$NM" | grep 'network-manager-enabled' | awk -F ":" '{print $2}'`

   if [[ $NMSTATUS =~ "okay" ]] ; then
      echo -e "Network-Manager check: $infra: ${GREEN}[passed]${NC}"
   else
      echo -e "Network-Manager check: $infra: ${RED}[failed]${NC} - reason: check details"
   fi
   echo "Network-Manager details:"
   echo "$NM"
done

echo "NODES"
for node in $NODES
do
   NM=`$CITELLUS_BASE/citellus.py -v -d WARNING -i network-manager-enabled  pssa-$node/sosreport-*/ | grep network | sed 's/^.*\(plugins.*\).*$/\1/'`
   NMSTATUS=`echo "$NM" | grep 'network-manager-enabled' | awk -F ":" '{print $2}'`

   if [[ $NMSTATUS =~ "okay" ]] ; then
      echo -e "Network-Manager check: $node: ${GREEN}[passed]${NC}"
   else
      echo -e "Network-Manager check: $node: ${RED}[failed]${NC} - reason: check details"
   fi
   echo "Network-Manager details:"
   echo "$NM"
done




