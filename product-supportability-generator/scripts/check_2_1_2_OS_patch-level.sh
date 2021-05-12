#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version

KERNELVERSION_EXPECTED=""
SELINUXVERSION_EXPECTED=""
DOCKERVERSION_EXPECTED=""

for master in $MASTERNODES
do
   KERNELVERSION=`cat pssa-$master/sosreport-*/sos_commands/rpm/sh_-c_rpm* | grep 'kernel' | awk '{print $1;}' | sort`
   SELINUXVERSION=`cat pssa-$master/sosreport-*/sos_commands/rpm/sh_-c_rpm* | grep 'libselinux-' | awk '{print $1;}' | sort`
   DOCKERVERSION=`cat pssa-$master/sosreport-*/sos_commands/rpm/sh_-c_rpm* | grep 'docker-'|grep -v cockpit-docker | awk '{print $1;}' | sort`

   if [[ -z $KERNELVERSION_EXPECTED ]] ;then
      KERNELVERSION_EXPECTED=$KERNELVERSION
      echo "expected kernel packages:"
      echo "$KERNELVERSION_EXPECTED"
      SELINUXVERSION_EXPECTED=$SELINUXVERSION
      echo "expected SELinux packages:"
      echo "$SELINUXVERSION_EXPECTED"
      DOCKERVERSION_EXPECTED=$DOCKERVERSION
      echo "expected Docker packages:"
      echo "$DOCKERVERSION_EXPECTED"
      echo "MASTER NODES"
   fi

   if [ "$KERNELVERSION" = "$KERNELVERSION_EXPECTED" ] &&  [ "$SELINUXVERSION" = "$SELINUXVERSION_EXPECTED" ] && [ "$DOCKERVERSION" = "$DOCKERVERSION_EXPECTED" ] ; then
      echo -e "$master: ${GREEN}[passed]${NC}"
   else
      echo -e "$master: ${RED}[failed]${NC} - reason:" 
      if [ "$KERNELVERSION" != "$KERNELVERSION_EXPECTED" ] ; then
          echo "mismatch on kernel packages, as found:" 
          DIFF=`diff <(echo "$KERNELVERSION") <(echo "$KERNELVERSION_EXPECTED")` 
          echo "$DIFF"     
      fi
      if [ "$SELINUXVERSION" != "$SELINUXVERSION_EXPECTED" ] ; then
          echo "mismatch on SELinux packages, as found:" 
          DIFF=`diff <(echo "$SELINUXVERSION") <(echo "$SELINUXVERSION_EXPECTED")` 
          echo "$DIFF"     
      fi
      if [ "$DOCKERVERSION" != "$DOCKERVERSION_EXPECTED" ] ; then
          echo "mismatch on Docker packages, as found:" 
          DIFF=`diff <(echo "$DOCKERVERSION") <(echo "$DOCKERVERSION_EXPECTED")` 
          echo "$DIFF"   
      fi

   fi 

   REGEX="cockpit-docker[^\s]*"
   COCKPITPACKAGE=""
   TESTARR=($DOCKERVERSION_EXPECTED)
   for i in "${TESTARR[@]}"
   do
     if [[ $i =~ ^${REGEX}$ ]] ; then
        COCKPITPACKAGE="${i}"
     fi
   done

   if [[ $OCPMINORVERSION -lt 10 ]] ; then
      DOCKERVERSION_EXPECTED=${DOCKERVERSION_EXPECTED//$COCKPITPACKAGE/}
      DOCKERVERSION_EXPECTED=`echo "$DOCKERVERSION_EXPECTED" | sed '/^\s*$/d'`
   fi 
done


echo "INFRA NODES"
for infra in $INFRANODES
do
   KERNELVERSION=`cat pssa-$infra/sosreport-*/sos_commands/rpm/sh_-c_rpm* | grep 'kernel' | awk '{print $1;}' | sort`
   SELINUXVERSION=`cat pssa-$infra/sosreport-*/sos_commands/rpm/sh_-c_rpm* | grep 'libselinux-' | awk '{print $1;}' | sort`
   DOCKERVERSION=`cat pssa-$infra/sosreport-*/sos_commands/rpm/sh_-c_rpm* | grep 'docker-' | awk '{print $1;}' | sort`
  if [ "$KERNELVERSION" = "$KERNELVERSION_EXPECTED" ] &&  [ "$SELINUXVERSION" = "$SELINUXVERSION_EXPECTED" ] && [ "$DOCKERVERSION" = "$DOCKERVERSION_EXPECTED" ] ; then
      echo -e "$infra: ${GREEN}[passed]${NC}"
   else
      echo -e "$infra: ${RED}[failed]${NC} - reason:" 
      if [ "$KERNELVERSION" != "$KERNELVERSION_EXPECTED" ] ; then
          echo "mismatch on kernel packages, as found:"
          DIFF=`diff <(echo "$KERNELVERSION") <(echo "$KERNELVERSION_EXPECTED")` 
          echo "$DIFF"     
      fi
      if [ "$SELINUXVERSION" != "$SELINUXVERSION_EXPECTED" ] ; then
          echo "mismatch on SELinux packages, as found:" 
          DIFF=`diff <(echo "$SELINUXVERSION") <(echo "$SELINUXVERSION_EXPECTED")` 
          echo "$DIFF"     
      fi
      if [ "$DOCKERVERSION" != "$DOCKERVERSION_EXPECTED" ] ; then
          echo "mismatch on Docker packages, as found:" 
          DIFF=`diff <(echo "$DOCKERVERSION") <(echo "$DOCKERVERSION_EXPECTED")` 
          echo "$DIFF"   
      fi

   fi 
done

echo "NODES"
for node in $NODES
do
   KERNELVERSION=`cat pssa-$node/sosreport-*/sos_commands/rpm/sh_-c_rpm* | grep 'kernel' | awk '{print $1;}' | sort`
   SELINUXVERSION=`cat pssa-$node/sosreport-*/sos_commands/rpm/sh_-c_rpm* | grep 'libselinux-' | awk '{print $1;}' | sort`
   DOCKERVERSION=`cat pssa-$node/sosreport-*/sos_commands/rpm/sh_-c_rpm* | grep 'docker-' | awk '{print $1;}' | sort`
   if [ "$KERNELVERSION" = "$KERNELVERSION_EXPECTED" ] &&  [ "$SELINUXVERSION" = "$SELINUXVERSION_EXPECTED" ] && [ "$DOCKERVERSION" = "$DOCKERVERSION_EXPECTED" ] ; then
      echo -e "$node: ${GREEN}[passed]${NC}"
   else
      echo -e "$node: ${RED}[failed]${NC} - reason:" 
      if [ "$KERNELVERSION" != "$KERNELVERSION_EXPECTED" ] ; then
          echo "mismatch on kernel packages, as found:" 
          DIFF=`diff <(echo "$KERNELVERSION") <(echo "$KERNELVERSION_EXPECTED")` 
          echo "$DIFF"    
      fi
      if [ "$SELINUXVERSION" != "$SELINUXVERSION_EXPECTED" ] ; then
          echo "mismatch on SELinux packages, as found:" 
          DIFF=`diff <(echo "$SELINUXVERSION") <(echo "$SELINUXVERSION_EXPECTED")` 
          echo "$DIFF"     
      fi
      if [ "$DOCKERVERSION" != "$DOCKERVERSION_EXPECTED" ] ; then
          echo "mismatch on Docker packages, as found:" 
          DIFF=`diff <(echo "$DOCKERVERSION") <(echo "$DOCKERVERSION_EXPECTED")` 
          echo "$DIFF"     
      fi

   fi 
done

number_of_nodes
PACKAGEMISMATCH=`cat pssa-*/sos*/installed*|awk '{print $1}'|sort |uniq -c |grep -v "1 cockpit-" |grep -v "${NUMBEROFMASTER} atomic-openshift-master-" |grep -v "${NUMBEROFMASTER} etcd-" |grep -v "${NUMBEROFETCD} etcd-" |grep -v "${TOTALNUMBEROFNODES} "`
if [[ ! "$PACKAGEMISMATCH" = "" ]]  ; then
   echo -e "${BLUE}Note: not all packages are installed on all nodes.${NC}"
   echo "$PACKAGEMISMATCH"
fi

