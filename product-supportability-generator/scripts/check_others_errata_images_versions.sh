#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPVERSION_WITHOUT_ERRATA=`echo "$OCPMAJORVERSION.$OCPMINORVERSION" `

OCP_SERVICES_LATEST="ose-egress-router ose-pod"
OCP_SERVICES_ERRATA="ose-template-service-broker ose-ansible-service-broker ose-service-catalog ose-logging-fluentd ose-logging-elasticsearch5 oauth-proxy"
OCP_SERVICES_MINOR="ose-node ose-web-console ose-metrics-server metrics-hawkular-metrics metrics-heapster metrics-cassandra ose-control-plane registry-console"

OCPERRATA_EXPECTED=`cat pssa-${MASTERNODEARR[0]}/sosreport-*/sos_commands/rpm/package-data | grep 'atomic-openshift-node' | grep -v 'atomic-openshift-3'| awk -F "-" '{print $4}' | awk '{print $1;}' | sort`

for image in $OCP_SERVICES_LATEST
do
   RESULT=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*images_in_use.out | grep "${image}"`
   if [[ "$RESULT" = "" ]] ; then
      echo -e "Image version check for \"$image\": [skipped] - reason: image $image seems to be currently not is use"
   else
      VERSION_RESULT=`echo "$RESULT" | grep 'latest'`
      if [[ "$VERSION_RESULT" = "" ]] ; then
         echo -e "Image version check for \"$image\": ${YELLOW}[support limitation]${NC} - reason: image tag for $image is expected to be \"latest\", but found"
         echo "$RESULT"
      else
         echo -e "Image version check for \"$image\": ${GREEN}[passed]${NC} - reason: \"$image:latest\" found"
      fi
   fi
done

for image in $OCP_SERVICES_ERRATA
do
   RESULT=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*images_in_use.out | grep "${image}"`
   if [[ "$RESULT" = "" ]] ; then
      echo -e "Image version check for \"$image\": [skipped] - reason: image $image seems to be currently not is use"
   else
      VERSION_RESULT=`echo "$RESULT" | grep "${OCPERRATA_EXPECTED}"`
      if [[ "$VERSION_RESULT" = "" ]] ; then
         echo -e "Image version check for \"$image\": ${YELLOW}[support limitation]${NC} - reason: image tag for $image is expected to be \"v$OCPERRATA_EXPECTED\", but found"
         echo "$RESULT"
      else
         echo -e "Image version check for \"$image\": ${GREEN}[passed]${NC} - reason: \"$image:v$OCPERRATA_EXPECTED\" found"
      fi
   fi
done

for image in $OCP_SERVICES_MINOR
do
   RESULT=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*images_in_use.out | grep "${image}"`
   if [[ "$RESULT" = "" ]] ; then
      echo -e "Image version check for \"$image\": [skipped] - reason: image $image seems to be currently not is use"
   else
      VERSION_RESULT=`echo "$RESULT" | grep "${OCPVERSION_WITHOUT_ERRATA}"`
      if [[ "$VERSION_RESULT" = "" ]] ; then
         echo -e "Image version check for \"$image\": ${YELLOW}[support limitation]${NC} - reason: image tag for $image is expected to be \"v$OCPVERSION_WITHOUT_ERRATA\", but found"
         echo "$RESULT"
      else
         echo -e "Image version check for \"$image\": ${GREEN}[passed]${NC} - reason: \"$image:v$OCPVERSION_WITHOUT_ERRATA\" found"
      fi
   fi
done

