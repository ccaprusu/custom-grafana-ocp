#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "exploding master-nodes"
for master in $MASTERNODES
do
   #if [[ ! -e $master ]]; then
   #   mkdir -p $master
   #fi 
   if [[ -e $master.tar ]]; then
     #tar xvf ../$master.tar
     tar xvf $master.tar
     cd pssa-$master
     tar xvf $master-master-etcd.tar
     SOSREPORT=`ls sosreport*.tar.xz`
     tar xvf $SOSREPORT
     cd ..
   fi 
done

echo "exploding infra-nodes"
for infra in $INFRANODES
do
   #if [[ ! -e $infra ]]; then
   #   mkdir -p $infra
   #fi 
   if [[ -e $infra.tar ]]; then
     #tar xvf ../$infra.tar
     tar xvf $infra.tar
     cd pssa-$infra
     tar xvf $infra-node.tar
     SOSREPORT=`ls sosreport*.tar.xz`
     tar xvf $SOSREPORT
     cd ..
   fi    
done

echo "exploding nodes"
for node in $NODES
do
   #if [[ ! -e $node ]]; then
   #   mkdir -p $node
   #fi 
   #cd $node
   if [[ -e $node.tar ]]; then
     #tar xvf ../$node.tar
     tar xvf $node.tar
     cd pssa-$node
     tar xvf $node-node.tar
     SOSREPORT=`ls sosreport*.tar.xz`
     tar xvf $SOSREPORT
     cd ..
   fi  
done
echo "done"

