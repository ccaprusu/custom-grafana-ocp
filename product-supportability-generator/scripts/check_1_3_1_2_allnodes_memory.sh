#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

max_pods_in_cluster
MEMFACTOR=`expr $MAXPODCLUSTER / 1000`
MEM_EXPECTED=$(( 1500 * $MEMFACTOR ))
echo "Additional amount of Mem for master and external etcd based on max pod capacity: $MEM_EXPECTED"
MEM_EXPECTED=$(( $MASTER_MIN_MEM + $MEM_EXPECTED ))

echo "MASTER NODES"

for master in $MASTERNODES
do
 MEMORY=`cat pssa-$master/sosreport-*/sos_commands/memory/free_-m`
 TOTALMEM=( $(echo $MEMORY | awk -F " " '{print $8}') )
 if [ $TOTALMEM -lt $MEM_EXPECTED ] ; then
    echo -e "$master: ${RED}[failed]${NC} - reason: total mem of $TOTALMEM is less the expected $MEM_EXPECTED"
 else
    echo -e "$master: ${GREEN}[passed]${NC}"
 fi
done

if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
fi

for etcd in $ETCDNODES
do
 MEMORY=`cat pssa-$etcd/sosreport-*/sos_commands/memory/free_-m`
 TOTALMEM=( $(echo $MEMORY | awk -F " " '{print $8}') )
 if [ $TOTALMEM -lt $MEM_EXPECTED ] ; then
    echo -e "$etcd: ${RED}[failed]${NC} - reason: total mem of $TOTALMEM is less the expected $MEM_EXPECTED"
 else
    echo -e "$etcd: ${GREEN}[passed]${NC}"
 fi
done

echo "INFRA NODES"

for infra in $INFRANODES
do
   MEMORY=`cat pssa-$infra/sosreport-*/sos_commands/memory/free_-m`
   TOTALMEM=( $(echo $MEMORY | awk -F " " '{print $8}') )
 if [ $TOTALMEM -lt $NODE_MIN_MEM ] ; then
    echo -e "$infra: ${RED}[failed]${NC} - reason: total mem of $TOTALMEM is less the expected $NODE_MIN_MEM"
 else
    echo -e "$infra: ${GREEN}[passed]${NC}"
 fi
done

echo "NODES"

for nodes in $NODES
do
 MEMORY=`cat pssa-$nodes/sosreport-*/sos_commands/memory/free_-m`
 TOTALMEM=( $(echo $MEMORY | awk -F " " '{print $8}') )
 if [ $TOTALMEM -lt $NODE_MIN_MEM ] ; then
    echo -e "$nodes: ${RED}[failed]${NC} - reason: total mem of $TOTALMEM is less the expected $NODE_MIN_MEM"
 else
    echo -e "$nodes: ${GREEN}[passed]${NC}"
 fi
done

