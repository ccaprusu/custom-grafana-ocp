export PSSA_PATH=/var/tmp/pssa/tmp
oc get nodes --show-labels -o wide > $PSSA_PATH/$(hostname)_all_nodes.out
oc get pods --show-labels -o wide --all-namespaces > $PSSA_PATH/$(hostname)_all_pods.out
for PV in `oc get pv --no-headers=true|awk '{print $1}'`; do oc get pv $PV -o yaml;echo "----"; done >> $PSSA_PATH/$(hostname)_all_pvs.out
#for PVC in `oc get pv --all-namespaces --no-headers=true|awk '{print $1}'`; do oc get pv $PVC -o yaml;echo "----"; done >> $PSSA_PATH/$(hostname)_all_pvcs.out
for PROJ in `oc get project --no-headers=true|awk '{print $1}'`; do echo $PROJ;echo "******";oc get -n $PROJ pvc;echo "------"; oc get -n $PROJ pvc -o yaml;echo "******" ;done >> $PSSA_PATH/$(hostname)_all_pvcs.out
for SC in `oc get sc --no-headers=true|awk '{print $1}'`; do oc describe sc $SC ;echo "----"; done >> /$PSSA_PATH/$(hostname)_all_scs.out
#for PROJECT in `oc projects -q`; do for POD in `oc get po -n $PROJECT|grep -v NAME|awk '{print $1}'`; do echo -n $POD; oc get -o yaml po $POD -n $PROJECT|grep "image:"|sort -u ;done;done >> /$PSSA_PATH/$(hostname)_all_images_in_use.out
for PROJECT in `oc projects -q`; do for POD in `oc get po -n $PROJECT --no-headers=true|awk '{print $1}'`; do echo -n $POD; oc get -o yaml po $POD -n $PROJECT|grep "image:"|sort -u ;done;done >> /$PSSA_PATH/$(hostname)_all_images_in_use.out
mkdir $PSSA_PATH/projects
for PROJECT in `oc projects -q`; do oc describe project $PROJECT >> /$PSSA_PATH/projects/$(hostname)_project_$PROJECT.out;done
mkdir $PSSA_PATH/templates
for PROJECT in `oc projects -q`; do for TEMPL in `oc get templates -n ${PROJECT} 2>/dev/null|grep -v NAME |awk '{print $1}'`; do echo $PROJECT:$TEMPL 2>&1 >> /$PSSA_PATH/templates/$(hostname)_${PROJECT}_templates.out;oc get -o yaml template $TEMPL -n $PROJECT 2>&1 >> /$PSSA_PATH/templates/$(hostname)_${PROJECT}_templates.out ; done;done
