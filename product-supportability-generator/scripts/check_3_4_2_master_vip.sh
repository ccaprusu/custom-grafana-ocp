#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

# need an array to grep just the first master
IFS=' ' read -r -a master_array <<< "$MASTERNODES"

# we need a reference and grep server from first master
REF_SERVER=`grep "server:" pssa-${master_array[0]}/etc/origin/master/bootstrap.kubeconfig|awk '{print $2}'`
echo "Reference for VIP from ${master_array[0]} is: $REF_SERVER"

echo "MASTER NODES"


for master in $MASTERNODES
do
	CONF_SERVER_MASTER=`grep "server:" pssa-${master}/etc/origin/master/bootstrap.kubeconfig|awk '{print $2}'`
	if [[ "$CONF_SERVER_MASTER" = "$REF_SERVER" ]]; then
		echo -e "VIP check for server $master: ${GREEN}[passed]${NC}"
		#echo $CONF_SERVER
	else
		echo -e "VIP check for server $master: ${RED}[failed]${NC}"
		echo "VIP is not $REF_SERVER but $CONF_SERVER_MASTER"
	fi
done

echo "INFRA NODES"
for infra in $INFRANODES
	do
        CONF_SERVER_INFRA=`grep "server:" pssa-${infra}/node.kubeconfig|awk '{print $2}'`
        if [[ "$CONF_SERVER_INFRA" = "$REF_SERVER" ]]; then
                echo -e "VIP check for server $infra: ${GREEN}[passed]${NC}"
        else
                echo -e "VIP check for server $infra: ${RED}[failed]${NC}"
                echo "VIP is not $REF_SERVER but $CONF_SERVER_INFRA"
        fi
done

echo "NODES"
for node in $NODES
        do
        CONF_SERVER_NODE=`grep "server:" pssa-${node}/node.kubeconfig|awk '{print $2}'`
        if [[ "$CONF_SERVER_NODE" = "$REF_SERVER" ]]; then
                echo -e "VIP check for server $node: ${GREEN}[passed]${NC}"
        else
                echo -e "VIP check for server $node: ${RED}[failed]${NC}"
                echo "VIP is not $REF_SERVER but $CONF_SERVER_NODE"
        fi
done


