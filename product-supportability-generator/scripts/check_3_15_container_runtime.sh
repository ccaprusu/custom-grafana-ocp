#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`

echo "MASTER NODES"
for master in $MASTERNODES
do
   if [ -e pssa-$master/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$master/sosreport-*/etc/origin/node/node-config.yaml | grep container-runtime-endpoint -A1`
   elif [ -e pssa-$master/etc/origin/node/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$master/etc/origin/node/node-config.yaml | grep container-runtime-endpoint -A1`
   elif [ -e pssa-$master/tmp/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$master/tmp/node-config.yaml | grep container-runtime-endpoint -A1`
   elif [ -e pssa-$master/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$master/node-config.yaml | grep container-runtime-endpoint -A1`
   else
      echo -e "Container Runtime check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ $CRUNTIME = "" ]] ; then
      echo -e "Container Runtime check: $master: ${GREEN}[passed]${NC} - reason: default as unset"
   else
      if [ $CRUNTIME =~ "crio.sock" ] ; then
         if [ ${OCPMINOR} -gt 9 ] ; then
            echo -e "Container Runtime check: $master: ${GREEN}[passed]${NC}  - reason: CRI-O is supported for OCP $OCPVERSION"
         else
            if [ ${OCPMINOR} -gt 6 ] ; then
               echo -e "Container Runtime check: $master: ${YELLOW}[support limitation]${NC} - reason: CRI-O is in status \"tech preview\" for OCP $OCPVERSION"
            else
               echo -e "Container Runtime check: $master: ${RED}[failed]${NC} - reason: CRI-O is in not supported for OCP $OCPVERSION"
            fi
         fi
      else
          if [ $CRUNTIME =~ "docker.sock" ] ; then
              echo -e "Container Runtime check: $master: ${GREEN}[passed]${NC}  - reason: DOCKER is supported for OCP $OCPVERSION"
          else
              echo -e "Container Runtime check: $master: ${RED}[failed]${NC} - reason: unsupported container runtime"
          fi
      fi
      echo "Container Runtime:"
      echo "$CRUNTIME"
   fi 
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   if [ -e pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml | grep container-runtime-endpoint -A1`
   elif [ -e pssa-$infra/etc/origin/node/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$infra/etc/origin/node/node-config.yaml | grep container-runtime-endpoint -A1`
   elif [ -e pssa-$infra/tmp/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$infra/tmp/node-config.yaml | grep container-runtime-endpoint -A1`
   elif [ -e pssa-$infra/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$infra/node-config.yaml | grep container-runtime-endpoint -A1`
   else
      echo -e "Container Runtime check: $master: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ $CRUNTIME = "" ]] ; then
      echo -e "Container Runtime check: $infra: ${GREEN}[passed]${NC} - reason: default as unset"
   else
      if [ $CRUNTIME =~ "crio.sock" ] ; then
         if [ ${OCPMINOR} -gt 9 ] ; then
            echo -e "Container Runtime check: $infra: ${GREEN}[passed]${NC}  - reason: CRI-O is supported for OCP $OCPVERSION"
         else
            if [ ${OCPMINOR} -gt 6 ] ; then
               echo -e "Container Runtime check: $infra: ${YELLOW}[support limitation]${NC} - reason: CRI-O is in status \"tech preview\" for OCP $OCPVERSION"
            else
               echo -e "Container Runtime check: $infra: ${RED}[failed]${NC} - reason: CRI-O is in not supported for OCP $OCPVERSION"
            fi
         fi
      else
          if [ $CRUNTIME =~ "docker.sock" ] ; then
              echo -e "Container Runtime check: $infra: ${GREEN}[passed]${NC}  - reason: DOCKER is supported for OCP $OCPVERSION"
          else
              echo -e "Container Runtime check: $infra: ${RED}[failed]${NC} - reason: unsupported container runtime"
          fi
      fi
      echo "Container Runtime:"
      echo "$CRUNTIME"
   fi 
done

echo "NODES"
CRIOONLY=true
for node in $NODES
do
   if [ -e pssa-$node/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$node/sosreport-*/etc/origin/node/node-config.yaml | grep container-runtime-endpoint -A1`
   elif [ -e pssa-$node/etc/origin/node/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$node/etc/origin/node/node-config.yaml | grep container-runtime-endpoint -A1`
   elif [ -e pssa-$node/tmp/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$node/tmp/node-config.yaml | grep container-runtime-endpoint -A1`
   elif [ -e pssa-$node/node-config.yaml ] ;then
      CRUNTIME=`cat pssa-$node/node-config.yaml | grep container-runtime-endpoint -A1`
   else
      echo -e "Container Runtime check: $node: [skipped] - reason: OpenShift seems to be not installed on this node, not all data was collected"
      continue
   fi

   if [[ $CRUNTIME = "" ]] ; then
      echo -e "Container Runtime check: $node: ${GREEN}[passed]${NC} - reason: default as unset"
      CRIOONLY=false
   else
      if [ $CRUNTIME =~ "crio.sock" ] ; then
         if [ ${OCPMINOR} -gt 9 ] ; then
            echo -e "Container Runtime check: $node: ${GREEN}[passed]${NC}  - reason: CRI-O is supported for OCP $OCPVERSION"
         else
            if [ ${OCPMINOR} -gt 6 ] ; then
               echo -e "Container Runtime check: $node: ${YELLOW}[support limitation]${NC} - reason: CRI-O is in status \"tech preview\" for OCP $OCPVERSION"
            else
               echo -e "Container Runtime check: $node: ${RED}[failed]${NC} - reason: CRI-O is in not supported for OCP $OCPVERSION"
            fi
         fi
      else
          if [ $CRUNTIME =~ "docker.sock" ] ; then
              CRIOONLY=false
              echo -e "Container Runtime check: $node: ${GREEN}[passed]${NC}  - reason: DOCKER is supported for OCP $OCPVERSION"
          else
              echo -e "Container Runtime check: $node: ${RED}[failed]${NC} - reason: unsupported container runtime"
          fi
      fi
      echo "Container Runtime:"
      echo "$CRUNTIME"
   fi 
done
if [ $CRIOONLY = true ] ; then
   echo -e "${BLUE}Note: as all nodes are configured to use CRI-O, check on how container-image build is configured to work.${NC}"
fi


