#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`

echo "MASTER NODES"
for master in $MASTERNODES
do
   if [ -e pssa-$master/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$master/sosreport-*/etc/origin/node/node-config.yaml | grep HugePages`
   elif [ -e pssa-$master/etc/origin/node/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$master/etc/origin/node/node-config.yaml | grep HugePages`
   elif [ -e pssa-$master/tmp/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$master/tmp/node-config.yaml | grep HugePages`
   elif [ -e pssa-$master/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$master/node-config.yaml | grep HugePages`
   else
      echo -e "HugePages support check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ $HUGEPAGES = "" ]] ; then
      echo -e "HugePages support check: $master: ${GREEN}[passed]${NC} - reason: default as unset"
   else
      if [ $HUGEPAGES =~ "true" ] ; then
         if [ ${OCPMINOR} -gt 10 ] ; then
            echo -e "HugePages support check: $master: ${GREEN}[passed]${NC}  - reason: HugePages is supported for OCP $OCPVERSION"
         else
            if [ ${OCPMINOR} -gt 9 ] ; then
               echo -e "HugePages support check: $master: ${YELLOW}[support limitation]${NC} - reason: HugePages is in status \"tech preview\" for OCP $OCPVERSION"
            else
               echo -e "HugePages support check: $master: ${RED}[failed]${NC} - reason: HugesPages is in not supported for OCP $OCPVERSION"
            fi
         fi
      else
         echo -e "HugePages support check: $master: ${RED}[manual check required]${NC}  - reason: rules seems to not match"
      fi
      echo "HugePages support details:"
      echo "$HUGEPAGES"
   fi 
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   if [ -e pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml | grep HugePages`
   elif [ -e pssa-$infra/etc/origin/node/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$infra/etc/origin/node/node-config.yaml | grep HugePages`
   elif [ -e pssa-$infra/tmp/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$infra/tmp/node-config.yaml | grep HugePages`
   elif [ -e pssa-$infra/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$infra/node-config.yaml | grep HugePages`
   else
      echo -e "HugePages support check: $infra: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ $HUGEPAGES = "" ]] ; then
      echo -e "HugePages support check: $infra: ${GREEN}[passed]${NC} - reason: default as unset"
   else
      if [ $HUGEPAGES =~ "true" ] ; then
         if [ ${OCPMINOR} -gt 10 ] ; then
            echo -e "HugePages support check: $infra: ${GREEN}[passed]${NC}  - reason: HugePages is supported for OCP $OCPVERSION"
         else
            if [ ${OCPMINOR} -gt 9 ] ; then
               echo -e "HugePages support check: $infra: ${YELLOW}[support limitation]${NC} - reason: HugePages is in status \"tech preview\" for OCP $OCPVERSION"
            else
               echo -e "HugePages support check: $v: ${RED}[failed]${NC} - reason: HugesPages is in not supported for OCP $OCPVERSION"
            fi
         fi
      else
         echo -e "HugePages support check: $infra: ${RED}[manual check required]${NC}  - reason: rules seems to not match"
      fi
      echo "HugePages support details:"
      echo "$HUGEPAGES"
   fi 
done

echo "NODES"
for node in $NODES
do
   if [ -e pssa-$node/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$node/sosreport-*/etc/origin/node/node-config.yaml | grep HugePages`
   elif [ -e pssa-$node/etc/origin/node/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$node/etc/origin/node/node-config.yaml | grep HugePages`
   elif [ -e pssa-$node/tmp/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$node/tmp/node-config.yaml | grep HugePages`
   elif [ -e pssa-$node/node-config.yaml ] ;then
      HUGEPAGES=`cat pssa-$node/node-config.yaml | grep HugePages`
   else
      echo -e "HugePages support check: $node: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ $HUGEPAGES = "" ]] ; then
      echo -e "HugePages support check: $node: ${GREEN}[passed]${NC} - reason: default as unset"
   else
      if [ $HUGEPAGES =~ "true" ] ; then
         if [ ${OCPMINOR} -gt 10 ] ; then
            echo -e "HugePages support check: $node: ${GREEN}[passed]${NC}  - reason: HugePages is supported for OCP $OCPVERSION"
         else
            if [ ${OCPMINOR} -gt 9 ] ; then
               echo -e "HugePages support check: $node: ${YELLOW}[support limitation]${NC} - reason: HugePages is in status \"tech preview\" for OCP $OCPVERSION"
            else
               echo -e "HugePages support check: $node: ${RED}[failed]${NC} - reason: HugesPages is in not supported for OCP $OCPVERSION"
            fi
         fi
      else
         echo -e "HugePages support check: $node: ${RED}[manual check required]${NC}  - reason: rules seems to not match"
      fi
      echo "HugePages support details:"
      echo "$HUGEPAGES"
   fi 
done
