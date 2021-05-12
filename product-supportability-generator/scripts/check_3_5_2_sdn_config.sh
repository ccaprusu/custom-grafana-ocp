#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

NETWORKNAME_EXPECTED=""
WARNING=""

for master in $MASTERNODES
do
   NETWORKNAME=`cat pssa-$master/etc/origin/master/master-config.yaml | grep 'networkConfig' -A9`

   if [[ -z $NETWORKNAME_EXPECTED ]] ;then
      NETWORKNAME_EXPECTED=$NETWORKNAME
      echo "configured OpenShift network:"
      echo "$NETWORKNAME_EXPECTED"
         
      NETWORKPLUGIN=`cat pssa-$master/etc/origin/master/master-config.yaml | grep 'networkPluginName'`
      if [[ ! "$NETWORKPLUGIN" =~ "$RHNETWORKPLUGINPATTERN" ]] && [[ ! -z $NETWORKNAME_EXPECTED ]] ; then
         WARNING="WARNING: \"$NETWORKPLUGIN\" is not a plugin supported by Red Hat!"
         echo -e "${YELLOW}${WARNING}${NC}"
      fi

      echo "MASTER NODES"
   fi
   if [[ -z $NETWORKNAME ]] ; then
     echo -e "$master: [skipped] - reason: OpenShift seems to be not installed on this node"
   else
   if [ "$NETWORKNAME" = "$NETWORKNAME_EXPECTED" ] ; then
      if [[ -z $WARNING ]] ; then
         echo -e "$master: ${GREEN}[passed]${NC}"
      else
         echo -e "$master: ${YELLOW}[support limitation]${NC} - reason: $WARNING"
      fi
   else
      echo -e "$master: ${RED}[failed]${NC} - found: $NETWORKNAME"
   fi 
   fi   

done
