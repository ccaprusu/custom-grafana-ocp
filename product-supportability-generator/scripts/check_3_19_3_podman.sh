#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version

echo "MASTER NODES"
for node in $MASTERNODES
do
   PODMAN=`cat pssa-$node/sosreport-*/sos_commands/rpm/package-data | grep 'podman' | awk '{print $1;}' | sort`
   if [ "$PODMAN" = "" ] ; then
      echo -e "$node: ${GREEN}[passed]${NC} - reason: feature not enabled because no related rpm is installed"
   else
      if ( [[ $OCPMINOR -lt 11 ]] ); then
         echo -e "$node: podman ${RED}[failed]${NC} -  - reason: for OCP $OCPVERSION podman is not supported"
      else
         echo -e "$node: podman ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION podman is in status \"Tech Preview\""
      fi
   fi
done

echo "INFRA NODES"
for node in $INFRANODES
do
   PODMAN=`cat pssa-$node/sosreport-*/sos_commands/rpm/package-data | grep 'podman' | awk '{print $1;}' | sort`
   if [ "$PODMAN" = "" ] ; then
      echo -e "$node: ${GREEN}[passed]${NC} - reason: feature not enabled because no related rpm is installed"
   else
      if ( [[ $OCPMINOR -lt 11 ]] ); then
         echo -e "$node: podman ${RED}[failed]${NC} -  - reason: for OCP $OCPVERSION podman is not supported"
      else
         echo -e "$node: podman ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION podman is in status \"Tech Preview\""
      fi
   fi
done


echo "NODES"
for node in $NODES
do
   PODMAN=`cat pssa-$node/sosreport-*/sos_commands/rpm/package-data | grep 'podman' | awk '{print $1;}' | sort`
   if [ "$PODMAN" = "" ] ; then
      echo -e "$node: ${GREEN}[passed]${NC} - reason: feature not enabled because no related rpm is installed"
   else
      if ( [[ $OCPMINOR -lt 11 ]] ); then
         echo -e "$node: podman ${RED}[failed]${NC} -  - reason: for OCP $OCPVERSION podman is not supported"
      else
         echo -e "$node: podman ${YELLOW}[support limitation]${NC} - reason: for OCP $OCPVERSION podman is in status \"Tech Preview\""
      fi
   fi
done
