#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`

HASCLOUDPROVIDER=false

echo "MASTER NODES"
for master in $MASTERNODES
do
   if [ -e pssa-$master/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$master/sosreport-*/etc/origin/node/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   elif [ -e pssa-$master/etc/origin/node/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$master/etc/origin/node/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   elif [ -e pssa-$master/tmp/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$master/tmp/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   elif [ -e pssa-$master/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$master/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   else
      echo -e "Cloud Provider check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ "$CLOUDPROVIDER" = "" &&  $HASCLOUDPROVIDER == false ]] ; then
      echo -e "Cloud Provider check: $master: ${GREEN}[passed]${NC} - reason: no cloud provider set"
   elif [[ "$CLOUDPROVIDER" = "" &&  $HASCLOUDPROVIDER == true ]] ; then
      echo -e "Cloud Provider check: $master: ${RED}[failed]${NC} - reason: this node has no cloud provider set, while other have"
   else
      HASCLOUDPROVIDER=true
      echo -e "Cloud Provider check: $master: ${GREEN}[passed]${NC} - reason: $CLOUDPROVIDER set"
   fi   
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   if [ -e pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   elif [ -e pssa-$infra/etc/origin/node/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$infra/etc/origin/node/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   elif [ -e pssa-$infra/tmp/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$infra/tmp/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   elif [ -e pssa-$infra/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$infra/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   else
      echo -e "Container Runtime check: $infra: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ "$CLOUDPROVIDER" = "" &&  $HASCLOUDPROVIDER == false ]] ; then
      echo -e "Cloud Provider check: $infra: ${GREEN}[passed]${NC} - reason: no cloud provider set"
   elif [[ "$CLOUDPROVIDER" = "" &&  $HASCLOUDPROVIDER == true ]] ; then
      echo -e "Cloud Provider check: $infra: ${RED}[failed]${NC} - reason: this node has no cloud provider set, while other have"
   else
      HASCLOUDPROVIDER=true
      echo -e "Cloud Provider check: $infra: ${GREEN}[passed]${NC} - reason: $CLOUDPROVIDER set"
   fi 
done

echo "NODES"
for node in $NODES
do
   if [ -e pssa-$node/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$node/sosreport-*/etc/origin/node/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   elif [ -e pssa-$node/etc/origin/node/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$node/etc/origin/node/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   elif [ -e pssa-$node/tmp/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$node/tmp/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   elif [ -e pssa-$node/node-config.yaml ] ;then
      CLOUDPROVIDER=`cat pssa-$node/node-config.yaml | grep cloud-provider -A1 | sed ':a;N;$!ba;s/\n/ /g'`
   else
      echo -e "Container Runtime check: $node: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ "$CLOUDPROVIDER" = "" &&  $HASCLOUDPROVIDER == false ]] ; then
      echo -e "Cloud Provider check: $node: ${GREEN}[passed]${NC} - reason: no cloud provider set"
   elif [[ "$CLOUDPROVIDER" = "" &&  $HASCLOUDPROVIDER == true ]] ; then
      echo -e "Cloud Provider check: $node: ${RED}[failed]${NC} - reason: this node has no cloud provider set, while other have"
   else
      HASCLOUDPROVIDER=true
      echo -e "Cloud Provider check: $node: ${GREEN}[passed]${NC} - reason: $CLOUDPROVIDER set"
   fi 
done
