#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "MASTER NODES"
for master in $MASTERNODES
do
   IPTABLES_SERVICE=`grep 'iptables' pssa-$master/sosreport-*/sos_commands/systemd/systemctl_list-units`
   FIREWALLD_SERVICE=`grep 'firewalld' pssa-$master/sosreport-*/sos_commands/systemd/systemctl_list-units`

   if [[ $IPTABLES_SERVICE = "" ]]; then
      if [[ $FIREWALLD_SERVICE = "" ]]; then
          echo -e "Iptables check: $master: ${RED}[failed]${NC} - reason: iptables nor firewalld are listed systemctl units"
      elif [[ ! $FIREWALLD_SERVICE =~ "active" ]]; then
          echo -e "Iptables check: $master: ${RED}[failed]${NC} - reason: firewalld is a service, but is not active as expected"          
      else
          echo -e "Iptables check: $master: ${GREEN}[passed]${NC} - reason: firewalld is an active service"
      fi
   elif [[ ! $IPTABLES_SERVICE =~ "active" ]]; then
      echo -e "Iptables check: $master: ${RED}[failed]${NC} - reason: iptables is not active as expected"
   else
      echo -e "Iptables check: $master: ${GREEN}[passed]${NC}"
   fi 
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   IPTABLES_SERVICE=`grep 'iptables' pssa-$infra/sosreport-*/sos_commands/systemd/systemctl_list-units`
   FIREWALLD_SERVICE=`grep 'firewalld' pssa-$infra/sosreport-*/sos_commands/systemd/systemctl_list-units`

   if [[ $IPTABLES_SERVICE = "" ]]; then
      if [[ $FIREWALLD_SERVICE = "" ]]; then
          echo -e "Iptables check: $infra: ${RED}[failed]${NC} - reason: iptables nor firewalld are listed systemctl units"
      elif [[ ! $FIREWALLD_SERVICE =~ "active" ]]; then
          echo -e "Iptables check: $infra: ${RED}[failed]${NC} - reason: firewalld is a service, but is not active as expected"          
      else
          echo -e "Iptables check: $infra: ${GREEN}[passed]${NC} - reason: firewalld is an active service"
      fi
   elif [[ ! $IPTABLES_SERVICE =~ "active" ]]; then
      echo -e "Iptables check: $infra: ${RED}[failed]${NC} - reason: iptables is not active as expected"
   else
      echo -e "Iptables check: $infra: ${GREEN}[passed]${NC}"
   fi 
done

echo "NODES"
for node in $NODES
do
   IPTABLES_SERVICE=`grep 'iptables' pssa-$node/sosreport-*/sos_commands/systemd/systemctl_list-units`
   FIREWALLD_SERVICE=`grep 'firewalld' pssa-$node/sosreport-*/sos_commands/systemd/systemctl_list-units`

   if [[ $IPTABLES_SERVICE = "" ]]; then
      if [[ $FIREWALLD_SERVICE = "" ]]; then
          echo -e "Iptables check: $node: ${RED}[failed]${NC} - reason: iptables nor firewalld are listed systemctl units"
      elif [[ ! $FIREWALLD_SERVICE =~ "active" ]]; then
          echo -e "Iptables check: $node: ${RED}[failed]${NC} - reason: firewalld is a service, but is not active as expected"          
      else
          echo -e "Iptables check: $node: ${GREEN}[passed]${NC} - reason: firewalld is an active service"
      fi
   elif [[ ! $IPTABLES_SERVICE =~ "active" ]]; then
      echo -e "Iptables check: $node: ${RED}[failed]${NC} - reason: iptables is not active as expected"
   else
      echo -e "Iptables check: $node: ${GREEN}[passed]${NC}"
   fi 
done
