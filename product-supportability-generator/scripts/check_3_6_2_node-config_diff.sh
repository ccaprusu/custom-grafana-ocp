#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

number_of_nodes

echo "MASTER NODES"
for master in $MASTERNODES
do
   echo "diff node-config.yaml ${MASTERNODEARR[0]} vs. $master" 
   if [ -e pssa-$master/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      DIFF=$(diff pssa-${MASTERNODEARR[0]}/sosreport-*/etc/origin/node/node-config.yaml pssa-$master/sosreport-*/etc/origin/node/node-config.yaml)
   elif [ -e pssa-$master/etc/origin/node/node-config.yaml ] ;then
      DIFF=$(diff pssa-${MASTERNODEARR[0]}/etc/origin/node/node-config.yaml pssa-$master/etc/origin/node/node-config.yaml)
   elif [ -e pssa-$master/tmp/node-config.yaml ] ;then
      DIFF=$(diff pssa-${MASTERNODEARR[0]}/tmp/node-config.yaml pssa-$master/tmp/node-config.yaml)
  elif [ -e pssa-$master/node-config.yaml ] ;then
      DIFF=$(diff pssa-${MASTERNODEARR[0]}/node-config.yaml pssa-$master/node-config.yaml)
   else
      echo -e "Node config check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   DIFF_CLEAN=`echo "$DIFF" | grep -v "dnsIP:" | grep -v "nodeName:" | grep -v "masterKubeConfig:"`
   echo "$DIFF_CLEAN"
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   echo "diff node-config.yaml ${INFRANODESARR[0]} vs. $infra" 
#   DIFF=$(diff pssa-${INFRANODESARR[0]}/sosreport-*/etc/origin/node/node-config.yaml pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml)

   if [ -e pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      DIFF=$(diff pssa-${INFRANODESARR[0]}/sosreport-*/etc/origin/node/node-config.yaml pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml)
   elif [ -e pssa-$infra/etc/origin/node/node-config.yaml ] ;then
      DIFF=$(diff pssa-${INFRANODESARR[0]}/etc/origin/node/node-config.yaml pssa-$infra/etc/origin/node/node-config.yaml)
   elif [ -e pssa-$infra/tmp/node-config.yaml ] ;then
      DIFF=$(diff pssa-${INFRANODESARR[0]}/tmp/node-config.yaml pssa-$infra/tmp/node-config.yaml)
   elif [ -e pssa-$infra/node-config.yaml ] ;then
      DIFF=$(diff pssa-${INFRANODESARR[0]}/node-config.yaml pssa-$infra/node-config.yaml)
   else
      echo -e "Node config check: $infra: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   DIFF_CLEAN=`echo "$DIFF" | grep -v "dnsIP:" | grep -v "nodeName:" | grep -v "masterKubeConfig:"`
   echo "$DIFF_CLEAN"
done

echo "NODES"
for node in $NODES
do
   echo "diff node-config.yaml ${NODESARR[0]} vs. $node" 
#   DIFF=$(diff pssa-${NODESARR[0]}/sosreport-*/etc/origin/node/node-config.yaml pssa-$node/sosreport-*/etc/origin/node/node-config.yaml)

   if [ -e pssa-$node/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      DIFF=$(diff pssa-${NODESARR[0]}/sosreport-*/etc/origin/node/node-config.yaml pssa-$node/sosreport-*/etc/origin/node/node-config.yaml)
   elif [ -e pssa-$node/etc/origin/node/node-config.yaml ] ;then
      DIFF=$(diff pssa-${NODESARR[0]}/etc/origin/node/node-config.yaml pssa-$node/etc/origin/node/node-config.yaml)
   elif [ -e pssa-$node/tmp/node-config.yaml ] ;then
      DIFF=$(diff pssa-${NODESARR[0]}/tmp/node-config.yaml pssa-$node/tmp/node-config.yaml)
   elif [ -e pssa-$node/node-config.yaml ] ;then
      DIFF=$(diff pssa-${NODESARR[0]}/node-config.yaml pssa-$node/node-config.yaml)
   else
      echo -e "Node config check: $node: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   DIFF_CLEAN=`echo "$DIFF" | grep -v "dnsIP:" | grep -v "nodeName:" | grep -v "masterKubeConfig:"`
   echo "$DIFF_CLEAN"
done
