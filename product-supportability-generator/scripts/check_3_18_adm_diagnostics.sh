#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

for master in $MASTERNODES
do
   if [ ! -e pssa-$master/sosreport-*/sos_commands/origin/oc_--config_.etc.origin.master.admin.kubeconfig_adm_diagnostics_-l_0 ] ; then
     echo -e "adm diagnostics check: $node: [skipped] - reason: seems \"pssa-$master/sosreport-*/sos_commands/origin/oc_--config_.etc.origin.master.admin.kubeconfig_adm_diagnostics_-l_0\" is not available"
   else
     SUMMARY=`tail -3 pssa-$master/sosreport-*/sos_commands/origin/oc_--config_.etc.origin.master.admin.kubeconfig_adm_diagnostics_-l_0` 
     if [[ ! $SUMMARY =~ "Errors seen: 0" ]] ; then
        echo -e "adm diagnostics check: $master: ${RED}[failed]${NC} - reason: report contains errors, please check \"pssa-$master/sosreport-*/sos_commands/origin/oc_--config_.etc.origin.master.admin.kubeconfig_adm_diagnostics_-l_0\"for details"
     else 
        if [[ ! $SUMMARY =~ "Warnings seen: 0" ]] ; then
           echo -e "adm diagnostics check: $master: ${YELLOW}[support limitation]${NC} - reason: report contains warnings, please check \"pssa-$master/sosreport-*/sos_commands/origin/oc_--config_.etc.origin.master.admin.kubeconfig_adm_diagnostics_-l_0\"for details"
        else
           echo -e "adm diagnostics check: $master: ${GREEN}[passed]${NC}  - reason: no error and no warning detected"
        fi
     fi 
     echo "$SUMMARY"
   fi
done
