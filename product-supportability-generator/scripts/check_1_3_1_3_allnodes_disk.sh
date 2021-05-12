#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version

REF_DOCKERSTORAGEDRIVERRUN=`awk  '/storage-driver/ { for (x=1;x<=NF;x++) if ($x~"--storage-driver") print $(x+1) }' pssa-${MASTERNODEARR[0]}/sosreport-*/ps`

echo "MASTER NODES"

for master in $MASTERNODES
do
 DISK=`cat pssa-$master/sosreport-*/sos_commands/filesys/df_-al_* | grep /dev/`
 DOCKER=`cat pssa-$master/sosreport-*/sos_commands/docker/docker_info | grep "Data Space Available"`
 FSTAB=`egrep '^/|^UUID' pssa-$master/sosreport-*/etc/fstab`
 DOCKERSTORAGEDRIVER=`awk '/storage-driver/{ print $2 }' pssa-$master/sosreport-*/etc/sysconfig/docker-storage`
 DOCKERSTORAGEDRIVERRUN=`awk  '/storage-driver/ { for (x=1;x<=NF;x++) if ($x~"--storage-driver") print $(x+1) }' pssa-$master/sosreport-*/ps`
 if [[ ! ${DOCKERSTORAGEDRIVER} = ${DOCKERSTORAGEDRIVERRUN} ]]; then
    echo "$master: ${RED}[failed]${NC}- reason: docker storage-driver in use \"${DOCKERSTORAGEDRIVERRUN}\" not equals the configured \"${DOCKERSTORAGEDRIVER}\""
 fi
 echo "$master: Disk $DISK"
 echo " - sftab:"
 echo "$FSTAB"
 echo "Docker $DOCKER using storage-driver: $DOCKERSTORAGEDRIVERRUN"
   if [ "$DOCKERSTORAGEDRIVERRUN" = "$REF_DOCKERSTORAGEDRIVERRUN" ]; then
      echo "Docker $DOCKER using storage-driver: $DOCKERSTORAGEDRIVERRUN"
   else
      echo -e "Docker $DOCKER using storage-driver: ${YELLOW}$DOCKERSTORAGEDRIVERRUN${NC}- ${BLUE}Note: this docker-storage-driver differs from the one configured on the reference node.${NC}"
   fi
done

echo ""
echo "INFRA NODES"

for infra in $INFRANODES
do
 DISK=`cat pssa-$infra/sosreport-*/sos_commands/filesys/df_-al* | grep /dev/`
 DOCKER=`cat pssa-$infra/sosreport-*/sos_commands/docker/docker_info | grep "Data Space Available"`
 FSTAB=`egrep '^/|^UUID' infra-$infra/sosreport-*/etc/fstab`
 DOCKERSTORAGEDRIVER=`awk '/storage-driver/{ print $2 }' pssa-$infra/sosreport-*/etc/sysconfig/docker-storage`
 DOCKERSTORAGEDRIVERRUN=`awk  '/storage-driver/ { for (x=1;x<=NF;x++) if ($x~"--storage-driver") print $(x+1) }' pssa-$infra/sosreport-*/ps`
 if [[ ! ${DOCKERSTORAGEDRIVER} = ${DOCKERSTORAGEDRIVERRUN} ]]; then
    echo "$infra: ${RED}[failed]${NC}- reason: docker storage-driver in use \"${DOCKERSTORAGEDRIVERRUN}\" not equals the configured \"${DOCKERSTORAGEDRIVER}\""
 fi
 echo "$infra: Disk $DISK"
 echo " - sftab:"
 echo "$FSTAB"
   if [ "$DOCKERSTORAGEDRIVERRUN" = "$REF_DOCKERSTORAGEDRIVERRUN" ]; then
      echo "Docker $DOCKER using storage-driver: $DOCKERSTORAGEDRIVERRUN"
   else
      echo -e "Docker $DOCKER using storage-driver: ${YELLOW}$DOCKERSTORAGEDRIVERRUN${NC}- ${BLUE}Note: this docker-storage-driver differs from the one configured on the reference node.${NC}"
   fi
done

echo ""
echo "NODES"

for nodes in $NODES
do
 DISK=`cat pssa-$nodes/sosreport-*/sos_commands/filesys/df_-al* | grep /dev/`
 DOCKER=`cat pssa-$nodes/sosreport-*/sos_commands/docker/docker_info | grep "Data Space Available"`
 FSTAB=`egrep '^/|^UUID' pssa-$nodes/sosreport-*/etc/fstab`
 DOCKERSTORAGEDRIVER=`awk '/storage-driver/{ print $2 }' pssa-$nodes/sosreport-*/etc/sysconfig/docker-storage`
 DOCKERSTORAGEDRIVERRUN=`awk  '/storage-driver/ { for (x=1;x<=NF;x++) if ($x~"--storage-driver") print $(x+1) }' pssa-$nodes/sosreport-*/ps`
 if [[ ! ${DOCKERSTORAGEDRIVER} = ${DOCKERSTORAGEDRIVERRUN} ]]; then
    echo "$nodes: ${RED}[failed]${NC}- reason: docker storage-driver in use \"${DOCKERSTORAGEDRIVERRUN}\" not equals the configured \"${DOCKERSTORAGEDRIVER}\""
 fi
 echo "$nodes: Disk $DISK"
 echo " - sftab:"
 echo "$FSTAB"
   if [ "$DOCKERSTORAGEDRIVERRUN" = "$REF_DOCKERSTORAGEDRIVERRUN" ]; then
      echo "Docker $DOCKER using storage-driver: $DOCKERSTORAGEDRIVERRUN"
   else
      echo -e "Docker $DOCKER using storage-driver: ${YELLOW}$DOCKERSTORAGEDRIVERRUN${NC}- ${BLUE}Note: this docker-storage-driver differs from the one configured on the reference node.${NC}"
   fi
done

