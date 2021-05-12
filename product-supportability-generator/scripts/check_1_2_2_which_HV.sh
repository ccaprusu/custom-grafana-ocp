#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "MASTER NODES"
for master in $MASTERNODES
do
   PRODUCT=`cat pssa-$master/sosreport-*/dmidecode | grep 'Product Name'`
   echo "$master: $PRODUCT"
done

if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
fi

for etcd in $ETCDNODES
do
   PRODUCT=`cat pssa-$etcd/sosreport-*/dmidecode | grep 'Product Name'`
   echo "$etcd: $PRODUCT"
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   PRODUCT=`cat pssa-$infra/sosreport-*/dmidecode | grep 'Product Name'`
   echo "$infra: $PRODUCT"
done

echo "NODES"
for node in $NODES
do
   PRODUCT=`cat pssa-$node/sosreport-*/dmidecode | grep 'Product Name'`
   echo "$node: $PRODUCT"
done
