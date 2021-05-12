#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "MASTER NODES"
for master in $MASTERNODES
do
   if [ ! -e pssa-$master/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml ] ; then
     echo -e "adm diagnostics NodeConfigCheck check: $master: [skipped] - reason: seems \"pssa-$master/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml\" is not available"
   else
     SUMMARY=`cat pssa-$master/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml | grep 'Completed with no errors or warnings seen'` 
     if [[ ! $SUMMARY = "" ]] ; then
        echo -e "adm diagnostics NodeConfigCheck check: $master: ${GREEN}[passed]${NC}  - reason: no error and no warning detected"
     else 
        echo -e "adm diagnostics NodeConfigCheck check: $master: ${RED}[failed]${NC} - reason: completed with errors or warnings seen, please check \"pssa-$master/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml\"for details"
     fi 
   fi
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   if [ ! -e pssa-$infra/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml ] ; then
     echo -e "adm diagnostics NodeConfigCheck check: $infra: [skipped] - reason: seems \"pssa-$infra/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml\" is not available"
   else
     SUMMARY=`cat pssa-$infra/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml | grep 'Completed with no errors or warnings seen'` 
     if [[ ! $SUMMARY = "" ]] ; then
        echo -e "adm diagnostics NodeConfigCheck check: $infra: ${GREEN}[passed]${NC}  - reason: no error and no warning detected"
     else 
        echo -e "adm diagnostics NodeConfigCheck check: $infra: ${RED}[failed]${NC} - reason: completed with errors or warnings seen, please check \"pssa-$infra/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml\"for details"
     fi 
   fi
done

echo "NODES"
for node in $NODES
do
   if [ ! -e pssa-$node/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml ] ; then
     echo -e "adm diagnostics NodeConfigCheck check: $node: [skipped] - reason: seems \"pssa-$node/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml\" is not available"
   else
     SUMMARY=`cat pssa-$node/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml | grep 'Completed with no errors or warnings seen'` 
     if [[ ! $SUMMARY = "" ]] ; then
        echo -e "adm diagnostics NodeConfigCheck check: $node: ${GREEN}[passed]${NC}  - reason: no error and no warning detected"
     else 
        echo -e "adm diagnostics NodeConfigCheck check: $node: ${RED}[failed]${NC} - reason: completed with errors or warnings seen, please check \"pssa-$node/sosreport-*/sos_commands/origin/oc_adm_diagnostics_NodeConfigCheck_--node-config_.etc.origin.node.node-config.yaml\"for details"
     fi 
   fi
done
