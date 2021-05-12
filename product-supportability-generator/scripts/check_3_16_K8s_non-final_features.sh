#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

 MASTERNODEARR=($MASTERNODES)
ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`

if [ -e pssa-${MASTERNODEARR[0]}/sos*/etc/origin/master/master-config.yaml ] ;then
   K8S_ALPHA=`cat pssa-${MASTERNODEARR[0]}/sos*/etc/origin/master/master-config.yaml | grep 'apis/settings.k8s.io/v1alpha1' `
elif [ -e pssa-${MASTERNODEARR[0]}/etc/origin/master/master-config.yaml ] ;then
   K8S_ALPHA=`cat pssa-${MASTERNODEARR[0]}/etc/origin/master/master-config.yaml | grep 'apis/settings.k8s.io/v1alpha1' `
else
   echo "no master-config.yaml found for node ${MASTERNODEARR[0]}"
fi
if [[ "$K8S_ALPHA" = "" ]] ; then
   echo -e "K8s alpa feature check: ${GREEN}[passed]${NC}- reason: not set in master-config"
else
   echo -e "K8s alpa feature check: ${YELLOW}[support limitation]${NC}- reason: found \"$K8S_ALPHA\" in master-config"
fi

if [ $OCPMINOR -eq 9 ] ; then
    echo -e "Checking Kubernetes non-final features in scope of Openshift $OCPVERSION:"
   # Support paged LIST queries from the Kubernetes API
   echo -e "\"Support paged LIST queries from the Kubernetes API\" check: [skipped] - reason: check not yet implemented"

   # CustomResourceDefinitions, née Third Party Resources
   echo -e "\"CustomResourceDefinitions, née Third Party Resources\" check: [skipped] - reason: no data collected to be checked against"

   # Beta admission webhook
   echo -e "\"Beta admission webhook\" check: [skipped] - reason: check not yet implemented"

   # CronJobs (previously ScheduledJobs)
   echo -e "\"CronJobs (previously ScheduledJobs)\" check: [skipped] - reason: no data collected to be checked against"

  
   # Add support for resizing PVs
   STORAGECLASS=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_scs.out | grep 'allowVolumeExpansion' -B4`
   if [[ "$STORAGECLASS" = "" ]] ; then
          echo -e "\"support for resizing PVs\" check: [not applicable] - reason: not set on any storage class"
      else
          echo -e "\"support for resizing PVs\" check: ${GREEN}[passed]${NC}- reason: feature is supported in OpenShift $OCPVERSION"
          echo "Storage class details:"
          echo "$STORAGECLASS"
      fi

fi
