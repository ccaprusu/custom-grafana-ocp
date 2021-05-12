#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPVERSION_EXPECTED=$OCPVERSION
MASTERNODEARR=($MASTERNODES)

echo "MASTER NODES"
for master in $MASTERNODES
do
   DOCKERVERSION=`cat pssa-$master/sosreport-*/sos_commands/docker/docker_info | grep 'Server Version'`
   HOSTNAME=`cat pssa-$master/sosreport-*/hostname`
   K8SVERSION=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_nodes.out | grep $HOSTNAME | awk '{print $5}'`
   ARR=($K8SVERSION)
   K8SVERSION=`echo ${ARR[0]}`
   OCPVERSION=`cat pssa-$master/sosreport-*/sos_commands/rpm/package-data | grep 'atomic-openshift-node' | awk '{print $1}'| awk -F "-" '{print $4,$5}' | grep '3'`   
   ARR=($OCPVERSION)
   OCPVERSION=`echo ${ARR[1]} | awk -F "." '{print $1}'`
   OCPVERSION=`echo ${ARR[0]}-$OCPVERSION`

   if [ "$OCPVERSION" = "" ] ; then
      echo -e "$master: [skipped] - reason: as no valid OpenShift release was detected ($OCPVERSION) the product seems to be not installed"
   else

   if [[ ! "$OCPVERSION" = "$OCPVERSION_EXPECTED" ]] ; then
      echo -e "$master: ${RED}[failed]${NC} - reason: OCP $OCPVERSION is not the expected $OCPVERSION_EXPECTED"
   else
      OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'` 
      K8SMINOR=`echo "$K8SVERSION" | awk -F "." '{print $2}'`   
      if [ ${OCPMINOR} -gt 8 ] ; then
         if [[ "$DOCKERVERSION" =~ "1.13" ]] ; then
            if [[ $OCPMINOR -eq $K8SMINOR ]] ; then
               echo -e "$master: ${GREEN}[passed]${NC}"
            else
               echo -e "$master: ${RED}[failed]${NC} - reason: K8s version ($K8SVERSION) does not match OCP version $OCPVERSION "
            fi
         else
            echo -e "$master: ${RED}[failed]${NC} - reason: OCP 3.9 requires Docker 1.13"
         fi
      else
         if [[ "$DOCKERVERSION" =~ "1.12" ]] ; then
            echo -e "$master: ${GREEN}[passed]${NC}"
         else
            echo -e "$master: ${RED}[failed]${NC} - reason: OCP <3.9 requires Docker 1.12"
         fi
      fi
   fi
   fi
   echo " - OCP: $OCPVERSION"
   echo " - Docker: $DOCKERVERSION"
   echo " - K8s: $K8SVERSION"
done

if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
fi

for etcd in $ETCDNODES
do
   DOCKERVERSION=`cat pssa-$etcd/sosreport-*/sos_commands/docker/docker_info | grep 'Server Version'`
   HOSTNAME=`cat pssa-$etcd/sosreport-*/hostname`
   K8SVERSION=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_nodes.out | grep $HOSTNAME | awk '{print $5}'`
   ARR=($K8SVERSION)
   K8SVERSION=`echo ${ARR[0]}`
   OCPVERSION=`cat pssa-$etcd/sosreport-*/sos_commands/rpm/package-data | grep 'atomic-openshift-node' | awk '{print $1}'| awk -F "-" '{print $4,$5}' | grep '3'`   
   ARR=($OCPVERSION)
   OCPVERSION=`echo ${ARR[1]} | awk -F "." '{print $1}'`
   OCPVERSION=`echo ${ARR[0]}-$OCPVERSION`

   if [ "$OCPVERSION" = "" ] ; then
      echo -e "$etcd: [skipped] - reason: as no valid OpenShift release was detected ($OCPVERSION) the product seems to be not installed"
   else
   if [[ ! "$OCPVERSION" = "$OCPVERSION_EXPECTED" ]] ; then
      echo -e "$etcd: ${RED}[failed]${NC} - reason: OCP $OCPVERSION is not the expected $OCPVERSION_EXPECTED"
   else
      OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'` 
      K8SMINOR=`echo "$K8SVERSION" | awk -F "." '{print $2}'`    
      if [ ${OCPMINOR} -gt 8 ] ; then
         if [[ "$DOCKERVERSION" =~ "1.13" ]] ; then
            if [[ $OCPMINOR -eq $K8SMINOR ]] ; then
               echo -e "$etcd: ${GREEN}[passed]${NC}"
            else
               echo -e "$etcd: ${RED}[failed]${NC} - reason: K8s version $K8SVERSION does not match OCP version $OCPVERSION"
            fi
         else
            echo -e "$etcd: ${RED}[failed]${NC} - reason: OCP 3.9 requires Docker 1.13"
         fi
      else
         if [[ "$DOCKERVERSION" =~ "1.12" ]] ; then
            echo -e "$etcd: ${GREEN}[passed]${NC}"
         else
            echo -e "$etcd: ${RED}[failed]${NC} - reason: OCP <3.9 requires Docker 1.12"
         fi
      fi
   fi
   fi
   echo " - OCP: $OCPVERSION"
   echo " - Docker: $DOCKERVERSION"
   echo " - K8s: $K8SVERSION"
done

echo "INFRA NODES"

for infra in $INFRANODES
do
   DOCKERVERSION=`cat pssa-$infra/sosreport-*/sos_commands/docker/docker_info | grep 'Server Version'`
   HOSTNAME=`cat pssa-$infra/sosreport-*/hostname`
   K8SVERSION=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_nodes.out | grep $HOSTNAME | awk '{print $5}'`
   ARR=($K8SVERSION)
   K8SVERSION=`echo ${ARR[0]}`
   OCPVERSION=`cat pssa-$infra/sosreport-*/sos_commands/rpm/package-data | grep 'atomic-openshift-node' | awk '{print $1}'| awk -F "-" '{print $4,$5}' | grep '3'`   
   ARR=($OCPVERSION)
   OCPVERSION=`echo ${ARR[1]} | awk -F "." '{print $1}'`
   OCPVERSION=`echo ${ARR[0]}-$OCPVERSION`

   if [ "$OCPVERSION" = "" ] ; then
      echo -e "$infra: [skipped] - reason: as no valid OpenShift release was detected ($OCPVERSION) the product seems to be not installed"
   else
   if [[ ! "$OCPVERSION" = "$OCPVERSION_EXPECTED" ]] ; then
      echo -e "$infra: ${RED}[failed]${NC} - reason: OCP $OCPVERSION is not the expected $OCPVERSION_EXPECTED"
   else
      OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'` 
      K8SMINOR=`echo "$K8SVERSION" | awk -F "." '{print $2}'`    
      if [ ${OCPMINOR} -gt 8 ] ; then
         if [[ "$DOCKERVERSION" =~ "1.13" ]] ; then
            if [[ $OCPMINOR -eq $K8SMINOR ]] ; then
               echo -e "$infra: ${GREEN}[passed]${NC}"
            else
               echo -e "$infra: ${RED}[failed]${NC} - reason: K8s version ($K8SVERSION) does not match OCP version $OCPVERSION"
            fi
         else
            echo -e "$infra: ${RED}[failed]${NC} - reason: OCP 3.9 requires Docker 1.13"
         fi
      else
         if [[ "$DOCKERVERSION" =~ "1.12" ]] ; then
            echo -e "$infra: ${GREEN}[passed]${NC}"
         else
            echo -e "$infra: ${RED}[failed]${NC} - reason: OCP <3.9 requires Docker 1.12"
         fi
      fi
   fi
   fi
   echo " - OCP: $OCPVERSION"
   echo " - Docker: $DOCKERVERSION"
   echo " - K8s: $K8SVERSION"
done

echo "NODES"

for nodes in $NODES
do
   DOCKERVERSION=`cat pssa-$nodes/sosreport-*/sos_commands/docker/docker_info | grep 'Server Version'`
   HOSTNAME=`cat pssa-$nodes/sosreport-*/hostname`
   K8SVERSION=`cat pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/*_all_nodes.out | grep $HOSTNAME | awk '{print $5}'`
   ARR=($K8SVERSION)
   K8SVERSION=`echo ${ARR[0]}`
   OCPVERSION=`cat pssa-$nodes/sosreport-*/sos_commands/rpm/package-data | grep 'atomic-openshift-node' | awk '{print $1}'| awk -F "-" '{print $4,$5}' | grep '3'`   
   ARR=($OCPVERSION)
   OCPVERSION=`echo ${ARR[1]} | awk -F "." '{print $1}'`
   OCPVERSION=`echo ${ARR[0]}-$OCPVERSION`

   if [ "$OCPMINOR" = "" ] ; then
      echo -e "$nodes: [skipped] - reason: as no valid OpenShift release was detected ($OCPVERSION) the product seems to be not installed"
   else
   if [[ ! "$OCPVERSION" = "$OCPVERSION_EXPECTED" ]] ; then
      echo -e "$nodes: ${RED}[failed]${NC} - reason: OCP $OCPVERSION is not the expected $OCPVERSION_EXPECTED"
   else
      OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`  
      K8SMINOR=`echo "$K8SVERSION" | awk -F "." '{print $2}'`   
      if [ ${OCPMINOR} -gt 8 ] ; then
         if [[ "$DOCKERVERSION" =~ "1.13" ]] ; then
            if [[ $OCPMINOR -eq $K8SMINOR ]] ; then
               echo -e "$nodes: ${GREEN}[passed]${NC}"
            else
               echo -e "$nodes: ${RED}[failed]${NC} - reason: K8s version ($K8SVERSION) does not match OCP version $OCPVERSION"
            fi
         else
            echo -e "$nodes: ${RED}[failed]${NC} - reason: OCP 3.9 requires Docker 1.13"
         fi
      else
         if [[ "$DOCKERVERSION" =~ "1.12" ]] ; then
            echo -e "$nodes: ${GREEN}[passed]${NC}"
         else
            echo -e "$nodes: ${RED}[failed]${NC} - reason: OCP <3.9 requires Docker 1.12"
         fi
      fi
   fi
   fi
   echo " - OCP: $OCPVERSION"
   echo " - Docker: $DOCKERVERSION"
   echo " - K8s: $K8SVERSION"
done


