export PSSA_PATH=/var/tmp/pssa/tmp
oc get nodes --show-labels -o wide > $PSSA_PATH/$(hostname)_all_nodes.out
oc get pods --show-labels -o wide --all-namespaces > $PSSA_PATH/$(hostname)_all_pods.out
for PV in `oc get pv --no-headers=true|awk '{print $1}'`; do oc get pv $PV -o yaml;echo "----"; done >> $PSSA_PATH/$(hostname)_all_pvs.out
for PVC in `oc get pv --all-namespaces --no-headers=true|awk '{print $1}'`; do oc get pv $PVC -o yaml;echo "----"; done >> $PSSA_PATH/$(hostname)_all_pvcs.out
for SC in `oc get sc --no-headers=true|awk '{print $1}'`; do oc describe sc $SC ;echo "----"; done >> /$PSSA_PATH/$(hostname)_all_scs.out
