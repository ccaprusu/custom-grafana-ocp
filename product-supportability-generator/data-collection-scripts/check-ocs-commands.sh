#!/bin/bash
export PSSA_PATH=/var/tmp/pssa/tmp
echo "This is OCS valtidation script" > $PSSA_PATH/$(hostname)_ocs.out
echo "             *****            " >> $PSSA_PATH/$(hostname)_ocs.out
echo                                  >> $PSSA_PATH/$(hostname)_ocs.out
oc get po --all-namespaces |grep heketi  &> /dev/null
if [ $? -ne 0 ]
then echo "no ocs related pods found" >> $PSSA_PATH/$(hostname)_ocs.out
else
for NS in `oc get po --all-namespaces |awk '/heketi/ {print $1}'` 
do echo "checking OCS in namespace: $NS" >> $PSSA_PATH/$(hostname)_ocs.out
   echo                                         >> $PSSA_PATH/$(hostname)_ocs.out
   echo -e '\t' "*  currently used images by pods" >> $PSSA_PATH/$(hostname)_ocs.out
     for POD in `oc get po -n $NS --no-headers|awk '{print $1}'`
     do 
     printf "%80s" $POD                            >> $PSSA_PATH/$(hostname)_ocs.out
     oc -n $NS get pod $POD -o yaml|grep "image:.*access.redhat.com/rhgs3/rhgs"|uniq >> $PSSA_PATH/$(hostname)_ocs.out
     done
  echo >> $PSSA_PATH/$(hostname)_ocs.out
  echo -e '\t' "*  currently referred images by templates"   >> $PSSA_PATH/$(hostname)_ocs.out
     for TEMPL in `oc get templates -n $NS --no-headers|awk '{print $1}'`
     do
     TMPL_IMAGE=`oc -n $NS get template $TEMPL -o yaml|egrep -A2 IMAGE_|awk '/value/ {print $2}'|tr -t '\n' ':'|awk -F: '{print $1":"$2}'` 
       if [ "$TMPL_IMAGE" = "" ]
       #then  printf "%150s\n" "No fixed image set in template ${TEMPL}, possibly fresh/never upgraded install" >> $PSSA_PATH/$(hostname)_ocs.out
       then  printf "%90s %-120s\n" "$TEMPL    image:" "no fixed image version set"  >> $PSSA_PATH/$(hostname)_ocs.out
       else
       printf "%90s %-120s\n" "$TEMPL    image:"  $TMPL_IMAGE >> $PSSA_PATH/$(hostname)_ocs.out
       fi
     done
     echo -e '\t' "*  fetching gluster specific data" >> $PSSA_PATH/$(hostname)_ocs.out
     HEKETI_POD=$(oc get pod -n $NS |awk '/heketi/ {print $1}') 
     echo -e '\t\t' "    * $HEKETI_POD :" >> $PSSA_PATH/$(hostname)_ocs.out
     HEKETI_CLI_KEY=$(oc -n $NS describe po $HEKETI_POD  |awk '/HEKETI_ADMIN_KEY/ {print $2}')
     HEKETI_CLI_USER=admin
     FILE_NU=$(oc -n $NS exec $HEKETI_POD -- /bin/bash -c "heketi-cli --user $HEKETI_CLI_USER --secret $HEKETI_CLI_KEY volume list|grep -v block|wc -l")
     BLOCK_ID=($(oc -n $NS exec $HEKETI_POD -- /bin/bash -c "heketi-cli --user $HEKETI_CLI_USER --secret $HEKETI_CLI_KEY volume list"|awk -F : '/block/ {print $2}' |awk '{print $1}'))
     BLOCK_NU=${#BLOCK_ID[@]}
     echo -e '\t\t\t\t\t' "* number    of    file   volumes : $FILE_NU" >> $PSSA_PATH/$(hostname)_ocs.out
     echo -e '\t\t\t\t\t' "* number of block hosting volumes: $BLOCK_NU" >> $PSSA_PATH/$(hostname)_ocs.out
     if [ ${BLOCK_NU}  -ne  0 ]
     then 
        for i in ${!BLOCK_ID[@]}; do
        CMD=`oc -n $NS exec $HEKETI_POD -- /bin/bash -c "heketi-cli --user $HEKETI_CLI_USER --secret $HEKETI_CLI_KEY volume info ${BLOCK_ID[$i]}" |grep "^Block Volumes:" |tr -t ' ' '\n' |egrep -v "^Block|^Volumes:"|wc -l`
        echo -e '\t\t\t\t\t\t\t\t' "${BLOCK_ID[$i]}" has $CMD volumes               >> $PSSA_PATH/$(hostname)_ocs.out
        done
    fi
    done
echo                                                             >> $PSSA_PATH/$(hostname)_ocs.out
echo " ===========================================================" >> $PSSA_PATH/$(hostname)_ocs.out
echo                                                                >> $PSSA_PATH/$(hostname)_ocs.out
fi
