#!/bin/sh

oc exec -n kube-system master-etcd-$(hostname) -- mkdir -p /var/tmp/pssa/tmp
oc cp -n kube-system /var/tmp/pssa/etcd-commands.sh master-etcd-$(hostname):/var/tmp/pssa/tmp
oc exec -n kube-system master-etcd-$(hostname) -- chmod +x /var/tmp/pssa/tmp/etcd-commands.sh
oc exec -n kube-system master-etcd-$(hostname) /var/tmp/pssa/tmp/etcd-commands.sh
oc cp -n kube-system master-etcd-$(hostname):/var/tmp/pssa/tmp /var/tmp/pssa/tmp
oc exec -n kube-system master-etcd-$(hostname) -- rm -rf /var/tmp/pssa
