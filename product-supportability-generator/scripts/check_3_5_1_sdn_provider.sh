#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

NETWORKPLUGIN_EXPECTED=""
WARNING=""

for master in $MASTERNODES
do
   NETWORKPLUGIN=`cat pssa-$master/etc/origin/master/master-config.yaml | grep 'networkPluginName'`
   
   if [[ -z $NETWORKPLUGIN_EXPECTED ]] ;then
      NETWORKPLUGIN_EXPECTED=$NETWORKPLUGIN
      echo "configured OpenShift network-plugin:"
      echo "$NETWORKPLUGIN_EXPECTED"
      
      RHPLUGIN="redhat/openshift"
      if [[ ! "$NETWORKPLUGIN_EXPECTED" =~ "$RHNETWORKPLUGINPATTERN" ]] ; then
         WARNING="WARNING: \"$NETWORKPLUGIN_EXPECTED\" is not a plugin supported by Red Hat!"
         echo -e "${YELLOW}${WARNING}${NC}"
      fi

      echo "MASTER NODES"
   fi

   if [[ -z $NETWORKPLUGIN ]] ; then
     echo -e "$master: [skipped] - reason: OpenShift seems to be not installed on this node"
   else
   if [ "$NETWORKPLUGIN" = "$NETWORKPLUGIN_EXPECTED" ] ; then
      if [[ -z $WARNING ]] ; then
         echo -e "$master: ${GREEN}[passed]${NC}"
      else
         echo -e "$master: ${YELLOW}[support limitation]${NC} - reason: $WARNING"
      fi
   else
      echo -e "$master: ${RED}[failed]${NC} - found: $NETWORKPLUGIN"
   fi 
   fi 
done

