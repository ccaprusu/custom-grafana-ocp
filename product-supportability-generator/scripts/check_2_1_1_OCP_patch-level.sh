#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version

OCPVERSION_EXPECTED=""


for master in $MASTERNODES
do
   OCPVERSION=`cat pssa-$master/sosreport-*/sos_commands/rpm/package-data | grep 'atomic-openshift' | grep -v 'atomic-openshift-3'| awk '{print $1;}' | sort`
   if [[ -z $OCPVERSION_EXPECTED ]] ;then
      OCPVERSION_EXPECTED=$OCPVERSION
      echo "expected packages:"
      echo "$OCPVERSION_EXPECTED"

      if [[ ${OCPMINORVERSION} -gt 9 ]] &&  [[ ! "$OCPVERSION_EXPECTED" =~ "atomic-openshift-clients" || ! "$OCPVERSION_EXPECTED" =~ "atomic-openshift-node" || ! "$OCPVERSION_EXPECTED" =~ "atomic-openshift-hyperkube" ]] ; then
         echo -e "OpenShift packages installed: ${RED}[failed]${NC} - reason: missing mandatory packages"
      fi
      if [[ $OCPMINORVERSION -lt 10 ]] && [[ ! "$OCPVERSION_EXPECTED" =~ "atomic-openshift-master" || ! "$OCPVERSION_EXPECTED" =~ "atomic-openshift-clients"  ||  ! "$OCPVERSION_EXPECTED" =~ "atomic-openshift-node" ||  ! "$OCPVERSION_EXPECTED" =~ "atomic-openshift-utils" ]] ; then
         echo -e "OpenShift packages installed: ${RED}[failed]${NC} - reason: missing mandatory package atomic-openshift-master"
      fi


      echo "MASTER NODES"
   fi
   
   if [ "$OCPVERSION" = "$OCPVERSION_EXPECTED" ] ; then
      echo -e "$master: ${GREEN}[passed]${NC}"
   else
      echo -e "$master: ${RED}[failed]${NC} - found:" 
      DIFF=`diff <(echo "$OCPVERSION") <(echo "$OCPVERSION_EXPECTED")` 
      echo "$DIFF" 
   fi   
done

REGEX="atomic-openshift-master[^\s]*"
TESTARR=($OCPVERSION_EXPECTED)
for i in "${TESTARR[@]}"
do
  if [[ $i =~ ^${REGEX}$ ]] ; then
     MASTERPACKAGE="${i}"
  fi
done

OCPVERSION_EXPECTED=${OCPVERSION_EXPECTED//$MASTERPACKAGE/}
OCPVERSION_EXPECTED=`echo "$OCPVERSION_EXPECTED" | sed '/^\s*$/d'`

echo "INFRA NODES"
for infra in $INFRANODES
do
   OCPVERSION=`cat pssa-$infra/sosreport-*/sos_commands/rpm/package-data | grep 'atomic-openshift' | awk '{print $1;}' | sort`
   if [ "$OCPVERSION" = "$OCPVERSION_EXPECTED" ] ; then
      echo -e "$infra: ${GREEN}[passed]${NC}"
   else
      echo -e "$infra: ${RED}[failed]${NC} - found:" 
      DIFF=`diff <(echo "$OCPVERSION") <(echo "$OCPVERSION_EXPECTED")` 
      echo "$DIFF"
   fi
done

echo "NODES"
for node in $NODES
do
   OCPVERSION=`cat pssa-$node/sosreport-*/sos_commands/rpm/package-data | grep 'atomic-openshift' | awk '{print $1;}' | sort`
   if [ "$OCPVERSION" = "$OCPVERSION_EXPECTED" ] ; then
      echo -e "$node: ${GREEN}[passed]${NC}"
   else
      echo -e "$node: ${RED}[failed]${NC} - found:"
      DIFF=`diff <(echo "$OCPVERSION") <(echo "$OCPVERSION_EXPECTED")` 
      echo "$DIFF"
   fi
done

