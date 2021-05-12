#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

number_of_nodes

for master in $MASTERNODES
do
   if [ ! -e pssa-$master/etc/etcd/etcd.conf ] ; then
     echo -e "ETCD storage: $master: [skipped] - reason: OpenShift ETCD seems to be not installed on this node or not all data was collected"
   else
   DATADIR=`cat  pssa-$master/etc/etcd/etcd.conf | grep 'ETCD_DATA_DIR'`
   BASEDIR=`echo "$DATADIR" | awk -F "/" '{print $2}'` 
   MOUNTPOINT=`cat pssa-$master/sosreport-*/sos_commands/filesys/df_-al_* | grep "/$DATADIR"`

   if [[ "$MOUNTPOINT" = "" ]]  ; then
      MOUNTPOINT=`cat pssa-$master/sosreport-*/sos_commands/filesys/df_-al_* | grep "/$BASEDIR"`
      echo -e "ETCD storage: ${YELLOW}[support limitation]${NC} - reason: consider exclusive volume for etcd to get max I/O"
   else
      echo -e "ETCD storage: ${GREEN}[passed]${NC} - reason: exclusive volume for etcd to get max I/O is used"
   fi
 
   MOUNTPOINT=`cat pssa-$master/sosreport-*/sos_commands/filesys/df_-al_* | grep "/$BASEDIR"`
   echo "$master: data-dir: $DATADIR mount-point:"
   echo "$MOUNTPOINT "
   fi
done
