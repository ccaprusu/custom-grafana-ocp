#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`

MASTERNODEARR=($MASTERNODES)
LABEL_CONFIGURED_NODES=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_nodes.out | grep 'volumes.kubernetes.io/controller-managed-attach-detach=false'`

echo "MASTER NODES"
for master in $MASTERNODES
do
   if [ -e pssa-$master/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$master/sosreport-*/etc/origin/node/node-config.yaml | grep enable-controller-attach-detach: -A1`
   elif [ -e pssa-$master/etc/origin/node/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$master/etc/origin/node/node-config.yaml | grep enable-controller-attach-detach: -A1`
   elif [ -e pssa-$master/tmp/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$master/tmp/node-config.yaml | grep enable-controller-attach-detach: -A1`
   elif [ -e pssa-$master/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$master/node-config.yaml | grep enable-controller-attach-detach: -A1`
   else
      echo -e "Controller-managed Attachment and Detachment Enabled check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

      if [[ $CONTROLLER_ATTACH = "" ]] ; then
         if [[ $LABEL_CONFIGURED_NODES =~ "$master" ]] ; then
            echo -e "Controller-managed Attachment and Detachment Enabled check: $master: ${YELLOW}[support limitation]${NC} - reason: If this node is lost, volumes that were attached to it can not be detached by the controller and reattached elsewhere"  
         else
            echo -e "Controller-managed Attachment and Detachment Enabled check: $master: ${GREEN}[passed]${NC} - reason: default as uset and not overwritten via node label"
         fi
      else
         if [[ $CONTROLLER_ATTACH =~ "false" ]] ; then  
            echo -e "Controller-managed Attachment and Detachment Enabled check: $master: ${YELLOW}[support limitation]${NC} - reason: If this node is lost, volumes that were attached to it can not be detached by the controller and reattached elsewhere"
         else
            echo -e "Controller-managed Attachment and Detachment Enabled check: $master: ${GREEN}[passed]${NC} - reason: set to true, what is the default to be enabled"
         fi
      fi 
done

echo "INFRA NODES"
for infra in $INFRANODES
do
    if [ -e pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml | grep enable-controller-attach-detach: -A1`
   elif [ -e pssa-$infra/etc/origin/node/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$infra/etc/origin/node/node-config.yaml | grep enable-controller-attach-detach: -A1`
   elif [ -e pssa-$infra/tmp/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$infra/tmp/node-config.yaml | grep enable-controller-attach-detach: -A1`
   elif [ -e pssa-$infra/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$infra/node-config.yaml | grep enable-controller-attach-detach: -A1`
   else
      echo -e "Controller-managed Attachment and Detachment Enabled check: $infra: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

      if [[ $CONTROLLER_ATTACH = "" ]] ; then
         if [[ $LABEL_CONFIGURED_NODES =~ "$infra" ]] ; then
            echo -e "Controller-managed Attachment and Detachment Enabled check: $infra: ${YELLOW}[support limitation]${NC} - reason: If this node is lost, volumes that were attached to it can not be detached by the controller and reattached elsewhere"  
         else
            echo -e "Controller-managed Attachment and Detachment Enabled check: $infra: ${GREEN}[passed]${NC} - reason: default as uset and not overwritten via node label"
         fi
      else
         if [[ $CONTROLLER_ATTACH =~ "false" ]] ; then  
            echo -e "Controller-managed Attachment and Detachment Enabled check: $infra: ${YELLOW}[support limitation]${NC} - reason: If this node is lost, volumes that were attached to it can not be detached by the controller and reattached elsewhere"
         else
            echo -e "Controller-managed Attachment and Detachment Enabled check: $infra: ${GREEN}[passed]${NC} - reason: set to true, what is the default to be enabled"
      fi
   fi 
done

echo "NODES"
for node in $NODES
do
   if [ -e pssa-$node/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$node/sosreport-*/etc/origin/node/node-config.yaml | grep enable-controller-attach-detach: -A1`
   elif [ -e pssa-$node/etc/origin/node/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$node/etc/origin/node/node-config.yaml | grep enable-controller-attach-detach: -A1`
   elif [ -e pssa-$node/tmp/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$node/tmp/node-config.yaml | grep enable-controller-attach-detach: -A1`
   elif [ -e pssa-$node/node-config.yaml ] ;then
      CONTROLLER_ATTACH=`cat pssa-$node/node-config.yaml | grep enable-controller-attach-detach: -A1`
   else
      echo -e "Controller-managed Attachment and Detachment Enabled check: $node: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

      if [[ $CONTROLLER_ATTACH = "" ]] ; then
         if [[ $LABEL_CONFIGURED_NODES =~ "$node" ]] ; then
            echo -e "Controller-managed Attachment and Detachment Enabled check: $node: ${YELLOW}[support limitation]${NC} - reason: If this node is lost, volumes that were attached to it can not be detached by the controller and reattached elsewhere"  
         else
            echo -e "Controller-managed Attachment and Detachment Enabled check: $node: ${GREEN}[passed]${NC} - reason: default as uset and not overwritten via node label"
         fi
      else
         if [[ $CONTROLLER_ATTACH =~ "false" ]] ; then  
            echo -e "Controller-managed Attachment and Detachment Enabled check: $node: ${YELLOW}[support limitation]${NC} - reason: If this node is lost, volumes that were attached to it can not be detached by the controller and reattached elsewhere"
         else
            echo -e "Controller-managed Attachment and Detachment Enabled check: $node: ${GREEN}[passed]${NC} - reason: set to true, what is the default to be enabled"
      fi
   fi 
done
