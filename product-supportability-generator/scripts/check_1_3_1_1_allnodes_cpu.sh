#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

max_pods_in_cluster
ocp_version
CPUFACTOR=`expr $MAXPODCLUSTER / 1000`
echo "No. of additional CPU(s) for master and external etcd based max pod capacity: $CPUFACTOR"
NOCPU_EXPECTED=`expr  $MASTER_MIN_CORE + $MAXPODCLUSTER / 1000`

echo "MASTER NODES"
for master in $MASTERNODES
do
   NUMBER_CPU=`cat pssa-$master/sosreport-*/sos_commands/processor/lscpu | grep 'CPU(s):'`
   NOCPU=( $(echo $NUMBER_CPU | awk -F " " '{print $2}') )
   if [ $NOCPU -lt $NOCPU_EXPECTED ] ; then
      echo -e "$master: ${RED}[failed]${NC} - reason: $NOCPU is less than the expected $NOCPU_EXPECTED cores" 
   else
      echo -e "$master: ${GREEN}[passed]${NC}"
   fi
  
   echo "$NUMBER_CPU"
done

if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
fi

for etcd in $ETCDNODES
do
   NUMBER_CPU=`cat pssa-$etcd/sosreport-*/sos_commands/processor/lscpu | grep 'CPU(s):'`
   NOCPU=( $(echo $NUMBER_CPU | awk -F " " '{print $2}') )
   if [ $NOCPU -lt $NOCPU_EXPECTED ] ; then
      echo -e "$etcd: ${RED}[failed]${NC} - reason: $NOCPU is less than the expected $NOCPU_EXPECTED cores" 
   else
      echo -e "$etcd: ${GREEN}[passed]${NC}"
   fi
  
   echo "$NUMBER_CPU"
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   if [ $OCPMINORVERSION -gt 9 ]; then
      PODS_PER_CORE='0'
   else
      PODS_PER_CORE=$DEFAULT_PODS_PER_CORE
   fi
   MAX_PODS=$DEFAULT_MAX_PODS
   NUMBER_CPU=`cat pssa-$infra/sosreport-*/sos_commands/processor/lscpu | grep 'CPU(s):'`
   if [ $NOCPU -lt 1 ] ; then
      echo -e "$infra: ${RED}[failed]${NC} - reason: $NOCPU is less than the expected cores" 
   else
      echo -e "$infra: ${GREEN}[passed]${NC}"
   fi
   echo "$NUMBER_CPU"
   if [ -e pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      XXX=`cat pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml | grep 'pods-per-core:' -A1 `
   elif [ -e pssa-$infra/etc/origin/node/node-config.yaml ] ;then
      XXX=`cat pssa-$infra/etc/origin/node/node-config.yaml | grep 'pods-per-core:' -A1 `
   elif [ -e pssa-$infra/tmp/node-config.yaml ] ;then
      XXX=`cat pssa-$infra/tmp/node-config.yaml | grep 'pods-per-core:' -A1 `
   elif [ -e pssa-$infra/node-config.yaml ] ;then
      XXX=`cat pssa-$infra/node-config.yaml | grep 'pods-per-core:' -A1 `
   else
      echo "no node-config.yaml found for node $infra"
   fi
   if [[ ! -z $XXX ]] ;then
      PODS_PER_CORE=( $(echo $XXX | awk -F "['\"]" '{print $2}') )
      echo -e " - ${YELLOW}pods-per-core customized: $PODS_PER_CORE${NC}"
   fi
   if [ -e pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      ZZZ=`cat pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml | grep 'max-pods:' -A1 `
   elif [ -e pssa-$infra/etc/origin/node/node-config.yaml ] ;then
      ZZZ=`cat pssa-$infra/etc/origin/node/node-config.yaml | grep 'max-pods:' -A1 `
   elif [ -e pssa-$infra/tmp/node-config.yaml ] ;then
      ZZZ=`cat pssa-$infra/tmp/node-config.yaml | grep 'max-pods:' -A1 `
   elif [ -e pssa-$infra/node-config.yaml ] ;then
      ZZZ=`cat pssa-$infra/node-config.yaml | grep 'max-pods:' -A1 `
   else
      echo "no node-config.yaml found for node $infra"
   fi
   if [[ ! -z $ZZZ ]] ;then
      MAX_PODS=( $(echo $ZZZ | awk -F "['\"]" '{print $2}') )
      echo -e " - ${YELLOW}max-pods customized: $MAX_PODS${NC}"
   fi 
   
   NUMBER_CPU=`cat pssa-$infra/sosreport-*/sos_commands/processor/lscpu | grep 'CPU(s):'`
   NOCPU=( $(echo $NUMBER_CPU | awk -F " " '{print $2}') )
#   MAXPOD=$( (( "$MAX_PODS" <= $NOCPU*$PODS_PER_CORE )) && echo "$MAX_PODS" || echo "$(( $NOCPU*$PODS_PER_CORE ))" ) 
   if (( $PODS_PER_CORE == '0' )) ; then
      MAXPOD=$MAX_PODS 
   else
      MAXPOD=$( (( "$MAX_PODS" <= $NOCPU*$PODS_PER_CORE )) && echo "$MAX_PODS" || echo "$(( $NOCPU*$PODS_PER_CORE ))" )
   fi
   echo " - max pods: $MAXPOD"
done

echo "NODES"
MAXPODCLUSTER=0
for nodes in $NODES
do
   if [ $OCPMINORVERSION -gt 9 ]; then
      PODS_PER_CORE='0'
   else
      PODS_PER_CORE=$DEFAULT_PODS_PER_CORE
   fi
   MAX_PODS=$DEFAULT_MAX_PODS
   NUMBER_CPU=`cat pssa-$nodes/sosreport*/sos_commands/processor/lscpu | grep 'CPU(s):'`
   if [ $NOCPU -lt 1 ] ; then
      echo -e "$nodes: ${RED}[failed]${NC} - reason: $NOCPU is less than the expected cores" 
   else
      echo -e "$nodes: ${GREEN}[passed]${NC}"
   fi
   echo "$NUMBER_CPU"
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
         echo -e " - ${YELLOW}pods-per-core customized: $PODS_PER_CORE${NC}"
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
         echo -e " - ${YELLOW}max-pods customized: $MAX_PODS${NC}"
      fi 

      NOCPU=( $(echo $NUMBER_CPU | awk -F " " '{print $2}') )
#   MAXPOD=$( (( "$MAX_PODS" <= $NOCPU*$PODS_PER_CORE )) && echo "$MAX_PODS" || echo "$(( $NOCPU*$PODS_PER_CORE ))" ) 
   if (( $PODS_PER_CORE == '0' )) ; then
      MAXPOD=$MAX_PODS 
   else
      MAXPOD=$( (( "$MAX_PODS" <= $NOCPU*$PODS_PER_CORE )) && echo "$MAX_PODS" || echo "$(( $NOCPU*$PODS_PER_CORE ))" )
   fi
      MAXPODCLUSTER=$(( $MAXPODCLUSTER + $MAXPOD ))
   
      echo " - max pods: $MAXPOD"
   fi
done
echo "================================"
echo "max app pods cluster: $MAXPODCLUSTER"
