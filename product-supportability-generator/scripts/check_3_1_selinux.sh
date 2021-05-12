#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "MASTER NODES"

for master in $MASTERNODES
do
   SELINUX=`$CITELLUS_BASE/citellus.py -v -d WARNING -i selinux pssa-$master/sosreport-*/. | grep selinux_ | sed 's/^.*\(plugins.*\).*$/\1/'`
   SELINUX_CONFIG=`echo "$SELINUX" | grep 'selinux_config.sh' | awk -F ":" '{print $2}'`
   SELINUX_RUNTIME=`echo "$SELINUX" | grep 'selinux_runtime' | awk -F ":" '{print $2}'`

   if [[ $SELINUX_CONFIG =~ "okay" ]] &&  [[ $SELINUX_RUNTIME =~ "okay" ]] ; then
      echo -e "SELinux check: $master: ${GREEN}[passed]${NC}"
   else
      echo -e "SELinux check: $master: ${RED}[failed]${NC} - reason: runtime &| config not-OK"
   fi
   echo "SELinux details:"
   echo "$SELINUX"
done

if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
fi

for etcd in $ETCDNODES
do
   SELINUX=`$CITELLUS_BASE/citellus.py -v -d WARNING -i selinux pssa-$etcd/sosreport-*/. | grep selinux_ | sed 's/^.*\(plugins.*\).*$/\1/'`
   SELINUX_CONFIG=`echo "$SELINUX" | grep 'selinux_config.sh' | awk -F ":" '{print $2}'`
   SELINUX_RUNTIME=`echo "$SELINUX" | grep 'selinux_runtime' | awk -F ":" '{print $2}'`

   if [[ $SELINUX_CONFIG =~ "okay" ]] &&  [[ $SELINUX_RUNTIME =~ "okay" ]] ; then
      echo -e "SELinux check: $etcd: ${GREEN}[passed]${NC}"
   else
      echo -e "SELinux check: $etcd: ${RED}[failed]${NC} - reason: runtime &| config not-OK"
   fi
   echo "SELinux details:"
   echo "$SELINUX"
done


echo "INFRA NODES"
for infra in $INFRANODES
do
   SELINUX=`$CITELLUS_BASE/citellus.py -v -d WARNING -i selinux pssa-$infra/sosreport-*/. | grep selinux_ | sed 's/^.*\(plugins.*\).*$/\1/'`
   SELINUX_CONFIG=`echo "$SELINUX" | grep 'selinux_config.sh' | awk -F ":" '{print $2}'`
   SELINUX_RUNTIME=`echo "$SELINUX" | grep 'selinux_runtime' | awk -F ":" '{print $2}'`

   if [[ $SELINUX_CONFIG =~ "okay" ]] &&  [[ $SELINUX_RUNTIME =~ "okay" ]] ; then
      echo -e "SELinux check: $infra: ${GREEN}[passed]${NC}"
   else
      echo -e "SELinux check: $infra: ${RED}[failed]${NC} - reason: runtime &| config not-OK"
   fi
   echo "SELinux details:"
   echo "$SELINUX"
done


echo "NODES"
for node in $NODES
do
   SELINUX=`$CITELLUS_BASE/citellus.py -v -d WARNING -i selinux pssa-$node/sosreport-*/. | grep selinux_ | sed 's/^.*\(plugins.*\).*$/\1/'`
   SELINUX_CONFIG=`echo "$SELINUX" | grep 'selinux_config.sh' | awk -F ":" '{print $2}'`
   SELINUX_RUNTIME=`echo "$SELINUX" | grep 'selinux_runtime' | awk -F ":" '{print $2}'`

   if [[ $SELINUX_CONFIG =~ "okay" ]] &&  [[ $SELINUX_RUNTIME =~ "okay" ]] ; then
      echo -e "SELinux check: $node: ${GREEN}[passed]${NC}"
   else
      echo -e "SELinux check: $node: ${RED}[failed]${NC} - reason: runtime &| config not-OK"
   fi
   echo "SELinux details:"
   echo "$SELINUX"
done
