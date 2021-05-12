#!/bin/sh

. $PWD/nodes.sh

CITELLUS_BASE="$HOME/git/citellus"
# double-check these setting for the OCP release in scope

DEFAULT_PODS_PER_CORE=10
DEFAULT_MAX_PODS=250
MASTER_MIN_CORE=4
MASTER_MIN_MEM=15800
NODE_MIN_MEM=7790
ALL_FS_TYPES="awsElasticBlockStore:|azureFile:|azureDisk:|cephfs:|cinder:|csi:|downwardAPI:|emptyDir:|fc:|flexVolume:|configMap:|flocker:|gcePersistentDisk:|gitRepo:|glusterfs:|hostPath:|iscsi:|local:|nfs:|persistentVolumeClaim:|projected:|portworxVolume:|quobyte:|rbd:|scaleIO:|secret:|storageos:|vsphereVolume:"
SUPPORTED_REGISTRY_FS_TYPES="awsElasticBlockStore: azureDisk: cephfs: fc: glusterfs: hostPath: iscsi: local: rbd: gcePersistentDisk:"
SUPPORTED_LOGGING_FS_TYPES="awsElasticBlockStore: azureDisk: gcePersistentDisk: iscsi: local: rbd: vsphereVolume:"
SUPPORTED_METRICS_FS_TYPES="awsElasticBlockStore: azureDisk: gcePersistentDisk: iscsi: local: rbd: vsphereVolume:"
SUPPORTED_PROMETHEUS_FS_TYPES="awsElasticBlockStore: azureDisk: gcePersistentDisk: iscsi: local: rbd: vsphereVolume:"
LOGGING_CURATOR_DEFAULT_DAYS=30
METRICSTROAGE_PER_NODE=0.175
METRICSTROAGE_PER_POD=0.004
PROMETHEUSSTROAGE_PER_NODE=0.0
PROMETHEUSSTROAGE_PER_POD=0.00512
LOGGING_BYTES_PER_SEC_PER_SEC=2560

# do NOT touch below as those declarations, functions, etc. are reused!

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
bold=$(tput bold)
normal=$(tput sgr0)

RHNETWORKPLUGINPATTERN="redhat/openshift"

ocp_version()
{
   MASTERNODEARR=($MASTERNODES) 
   OCPVERSION=`cat pssa-$MASTERNODEARR/sosreport-*/sos_commands/rpm/package-data | grep 'atomic-openshift-node' | awk '{print $1}'| awk -F "-" '{print $4,$5}' | grep '3'`   
   ARR=($OCPVERSION)
   OCPVERSION=`echo ${ARR[1]} | awk -F "." '{print $1}'`
   OCPVERSION=`echo ${ARR[0]}-$OCPVERSION`
   OCPMAJORVERSION=`echo "$OCPVERSION" | awk -F "." '{print $1}'`
   OCPMINORVERSION=`echo "$OCPVERSION" | awk -F "." '{print $2}'`
}

number_of_nodes()
{
   MASTERNODEARR=($MASTERNODES)
   NUMBEROFMASTER="${#MASTERNODEARR[*]}"
   ETCDNODESARR=($ETCDNODES)
   NUMBEROFETCD="${#ETCDNODESARR[*]}"
   INFRANODESARR=($INFRANODES)
   NUMBEROFINFRA="${#INFRANODESARR[*]}"
   NODESARR=($NODES)
   NUMBEROFNODES="${#NODESARR[*]}"
   TOTALNUMBEROFNODES=`expr $NUMBEROFMASTER + $NUMBEROFETCD + $NUMBEROFINFRA + $NUMBEROFNODES`
}

max_pods_in_cluster()
{
   ocp_version
   MAXPODCLUSTER=0
   for nodes in $NODES
   do
      if [ $OCPMINORVERSION -gt 9 ]; then
         PODS_PER_CORE='0'
      else
         PODS_PER_CORE=$DEFAULT_PODS_PER_CORE
      fi
      MAX_PODS=$DEFAULT_MAX_PODS
      NUMBER_CPU=`cat pssa-$nodes/sosreport-*/sos_commands/processor/lscpu | grep 'CPU(s):'`

      if [[ ! -z $NUMBER_CPU ]] ;then
         if [ -e pssa-$nodes/sosreport-*/etc/origin/node/node-config.yaml ] ;then
            XXX=`cat pssa-$nodes/sosreport-*/etc/origin/node/node-config.yaml | grep 'pods-per-core:' -A1 `
         elif [ -e pssa-$nodes/etc/origin/node/node-config.yaml ] ;then
            XXX=`cat pssa-$nodes/etc/origin/node/node-config.yaml | grep 'pods-per-core:' -A1 `
         elif [ -e pssa-$nodes/tmp/node-config.yaml ] ;then
            XXX=`cat pssa-$nodes/tmp/node-config.yaml | grep 'pods-per-core:' -A1 `
         elif [ -e pssa-$nodes/node-config.yaml ] ;then
            XXX=`cat pssa-$nodes/node-config.yaml | grep 'pods-per-core:' -A1 `
         else
            echo "no node-config.yaml found for node $nodes"
         fi
         if [[ ! -z $XXX ]] ;then
            PODS_PER_CORE=( $(echo $XXX | awk -F "['\"]" '{print $2}') )
         fi
         if [ -e pssa-$nodes/sosreport-*/etc/origin/node/node-config.yaml ] ;then
            ZZZ=`cat pssa-$nodes/sosreport-*/etc/origin/node/node-config.yaml | grep 'max-pods:' -A1 `
         elif [ -e pssa-$nodes/etc/origin/node/node-config.yaml ] ;then
            ZZZ=`cat pssa-$nodes/etc/origin/node/node-config.yaml | grep 'max-pods:' -A1 `
         elif [ -e pssa-$nodes/tmp/node-config.yaml ] ;then
            ZZZ=`cat pssa-$nodes/tmp/node-config.yaml | grep 'max-pods:' -A1 `
         elif [ -e pssa-$nodes/node-config.yaml ] ;then
            ZZZ=`cat pssa-$nodes/node-config.yaml | grep 'max-pods:' -A1 `
         else
            echo "no node-config.yaml found for node $nodes"
         fi
         if [[ ! -z $ZZZ ]] ;then
            MAX_PODS=( $(echo $ZZZ | awk -F "['\"]" '{print $2}') )
         fi 

         NOCPU=( $(echo $NUMBER_CPU | awk -F " " '{print $2}') )
         if (( $PODS_PER_CORE == '0' )) ; then
            MAXPOD=$MAX_PODS 
         else
            MAXPOD=$( (( "$MAX_PODS" <= $NOCPU*$PODS_PER_CORE )) && echo "$MAX_PODS" || echo "$(( $NOCPU*$PODS_PER_CORE ))" )
         fi
         MAXPODCLUSTER=$(( $MAXPODCLUSTER+$MAXPOD ))
      fi

   done
}

ocs_version()
{
   MASTERNODEARR=($MASTERNODES) 
   OCSVERSION=`cat pssa-$MASTERNODEARR/var/tmp/pssa/tmp/*ocs.out | grep 'access.redhat.com/rhgs3/rhgs' | awk -F ":" '{print $3}'` 
ARR=($OCSVERSION)
      OCSVERSION=`echo ${ARR[0]}`
   if [ "$OCSVERSION" = "latest" ]; then
      echo -e "OCS check: ${RED}[failed]${NC} - reason: OCS version tag is set to $OCSVERSION - this is super dangerous!"
      OCSMAJORVERSION="3"
      OCSMINORVERSION="latest"
   else
      OCSMAJORVERSION=`echo "$OCSVERSION" | awk -F "." '{print $1}'`
      OCSMINORVERSION=`echo "$OCSVERSION" | awk -F "." '{print $2}'`
   fi
}


