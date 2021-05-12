#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version

echo "OCPMINORVERSION: $OCPVERSION: $OCPMINORVERSION"

echo "MASTER NODES"
for master in $MASTERNODES
do
   DNS_RESOLV=(`cat pssa-$master/sosreport-*/etc/resolv.conf | grep 'nameserver' | awk '{print $2}'`)
   if [ -e pssa-$master/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$master/sosreport-*/etc/origin/node/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   elif [ -e pssa-$master/etc/origin/node/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$master/etc/origin/node/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   elif [ -e pssa-$master/tmp/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$master/tmp/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   elif [ -e pssa-$master/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$master/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   else
      echo "no node-config.yaml found for node $master"
   fi
   if [ $OCPMINORVERSION -gt 9 ]; then
      LOCALIP=`cat pssa-$master/sosreport-*/ip_addr | grep ${DNS_RESOLV[1]}`
      if [[ $LOCALIP != ""  &&  ${DNS_NODECONFIG} = "0.0.0.0" ]] ; then
         echo -e "$master: ${GREEN}[passed]${NC}"
      else
         echo -e "$master: ${RED}[failed]${NC} - reason: nameserver in resolv.conf (${DNS_RESOLV[1]}) or dnsip in node-config.yaml ($DNS_NODECONFIG) not as expected"
      fi
   else  
      if [[ ${DNS_RESOLV[1]} = ${DNS_NODECONFIG} ]] ; then
         echo -e "$master: ${GREEN}[passed]${NC}"
      else
         echo -e "$master: ${RED}[failed]${NC} - reason: nameserver in resolv.conf (${DNS_RESOLV[1]}) and dnsip in node-config.yaml ($DNS_NODECONFIG) do not match"
      fi
   fi
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   DNS_RESOLV=(`cat pssa-$infra/sosreport-*/etc/resolv.conf | grep 'nameserver' | awk '{print $2}'`)
   if [ -e pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$infra/sosreport-*/etc/origin/node/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   elif [ -e pssa-$infra/etc/origin/node/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$infra/etc/origin/node/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   elif [ -e pssa-$infra/tmp/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$infra/tmp/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   elif [ -e pssa-$infra/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$infra/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   else
      echo "no node-config.yaml found for node $infra"
   fi
   if [ $OCPMINORVERSION -gt 9 ]; then
      LOCALIP=`cat pssa-$infra/sosreport-*/ip_addr | grep ${DNS_RESOLV[1]}`
      if [[ $LOCALIP != ""  &&  ${DNS_NODECONFIG} = "0.0.0.0" ]] ; then
         echo -e "$infra: ${GREEN}[passed]${NC}"
      else
         echo -e "$infra: ${RED}[failed]${NC} - reason: nameserver in resolv.conf (${DNS_RESOLV[1]}) or dnsip in node-config.yaml ($DNS_NODECONFIG) not as expected"
      fi
   else  
      if [[ ${DNS_RESOLV[1]} = ${DNS_NODECONFIG} ]] ; then
         echo -e "$infra: ${GREEN}[passed]${NC}"
      else
         echo -e "$infra: ${RED}[failed]${NC} - reason: nameserver in resolv.conf (${DNS_RESOLV[1]}) and dnsip in node-config.yaml ($DNS_NODECONFIG) do not match"
      fi
   fi
done

echo "NODES"
for node in $NODES
do
   DNS_RESOLV=(`cat pssa-$node/sosreport-*/etc/resolv.conf | grep 'nameserver' | awk '{print $2}'`)
   if [ -e pssa-$node/sosreport-*/etc/origin/node/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$node/sosreport-*/etc/origin/node/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   elif [ -e pssa-$node/etc/origin/node/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$node/etc/origin/node/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   elif [ -e pssa-$node/tmp/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$node/tmp/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   elif [ -e pssa-$node/node-config.yaml ] ;then
      DNS_NODECONFIG=`cat pssa-$node/node-config.yaml | grep -i dnsip | awk -F " " '{print $2}'`
   else
      echo "no node-config.yaml found for node $node"
   fi
    if [ $OCPMINORVERSION -gt 9 ]; then
      LOCALIP=`cat pssa-$node/sosreport-*/ip_addr | grep ${DNS_RESOLV[1]}`
      if [[ $LOCALIP != ""  &&  ${DNS_NODECONFIG} = "0.0.0.0" ]] ; then
         echo -e "$node: ${GREEN}[passed]${NC}"
      else
         echo -e "$node: ${RED}[failed]${NC} - reason: nameserver in resolv.conf (${DNS_RESOLV[1]}) or dnsip in node-config.yaml ($DNS_NODECONFIG) not as expected"
      fi
   else  
      if [[ ${DNS_RESOLV[1]} = ${DNS_NODECONFIG} ]] ; then
         echo -e "$node: ${GREEN}[passed]${NC}"
      else
         echo -e "$node: ${RED}[failed]${NC} - reason: nameserver in resolv.conf (${DNS_RESOLV[1]}) and dnsip in node-config.yaml ($DNS_NODECONFIG) do not match"
      fi
   fi
done
