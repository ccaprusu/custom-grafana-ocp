#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`

RELEASE=`cat pssa-${MASTERNODEARR[0]}/sosreport*/etc/redhat-release`
REF_RELEASENO=`echo "$RELEASE" | awk -F " " '{print $7}'`

echo "MASTER NODES"
for master in $MASTERNODES
do
   RELEASE=`cat pssa-$master/sosreport*/etc/redhat-release`
   RELEASENO=`echo "$RELEASE" | awk -F " " '{print $7}'`
   UNAME=`cat pssa-$master/sosreport*/uname`

   if [ "$OCPMINOR" = "" ] ; then
      echo -e "OS version check: [skipped] - reason: as no valid OpenShift release was detected ($OCPVERSION) the product seems to be not installed"
   else
     if [ $OCPMINOR -eq 9 ] ; then
        if [ "$RELEASENO" = "7.3" ] || [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ]  || [ "$RELEASENO" = "7.6" ] ; then
            echo -e "OS version check: ${GREEN}[passed]${NC}"
        else
            echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
        fi
     elif [ $OCPMINOR -eq 7 ] || [ $OCPMINOR -eq 6 ] ; then
        if [ "$RELEASENO" = "7.3" ] || [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ] || [ "$RELEASENO" = "7.6" ]; then
            echo -e "OS version check: ${GREEN}[passed]${NC}"
        else
            echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
        fi
     else
        if [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ]  || [ "$RELEASENO" = "7.6" ] ; then
            echo -e "OS version check: ${GREEN}[passed]${NC}"
        else
            echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
        fi
     fi
   fi
   if [ "$RELEASENO" = "$REF_RELEASENO" ]; then
      echo -e " Red Hat release: $RELEASE; uname: $UNAME"
   else
      echo -e " Red Hat release: ${YELLOW}$RELEASE${NC}; uname: $UNAME"
   fi
  
done

if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
fi

for etcd in $ETCDNODES
do
   RELEASE=`cat pssa-$etcd/sosreport*/etc/redhat-release`
   RELEASENO=`echo "$RELEASE" | awk -F " " '{print $7}'`
   UNAME=`cat pssa-$etcd/sosreport*/uname`
   if [ "$OCPMINOR" = "" ] ; then
      echo -e "OS version check: [skipped] - reason: as no valid OpenShift release was detected ($OCPVERSION) the product seems to be not installed"
   else
   if [ $OCPMINOR -eq 9 ] ; then
      if [ "$RELEASENO" = "7.3" ] || [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ] || [ "$RELEASENO" = "7.6" ] ; then
          echo -e "OS version check: ${GREEN}[passed]${NC}"
      else
          echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
      fi
   elif [ $OCPMINOR -eq 7 ] || [ $OCPMINOR -eq 6 ] ; then
      if [ "$RELEASENO" = "7.3" ] || [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ] || [ "$RELEASENO" = "7.6" ] ; then
          echo -e "OS version check: ${GREEN}[passed]${NC}"
      else
          echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
      fi
     else
        if [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ]  || [ "$RELEASENO" = "7.6" ] ; then
            echo -e "OS version check: ${GREEN}[passed]${NC}"
        else
            echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
        fi
   fi
   fi
   if [ "$RELEASENO" = "$REF_RELEASENO" ]; then
      echo -e " Red Hat release: $RELEASE; uname: $UNAME"
   else
      echo -e " Red Hat release: ${YELLOW}$RELEASE${NC}; uname: $UNAME"
   fi

done

echo "INFRA NODES"
for infra in $INFRANODES
do  
   RELEASE=`cat pssa-$infra/sosreport*/etc/redhat-release`
   RELEASENO=`echo "$RELEASE" | awk -F " " '{print $7}'`
   UNAME=`cat pssa-$infra/sosreport*/uname`
   if [ "$OCPMINOR" = "" ] ; then
      echo -e "OS version check: [skipped] - reason: as no valid OpenShift release was detected ($OCPVERSION) the product seems to be not installed"
   else
   if [ $OCPMINOR -eq 9 ] ; then
      if [ "$RELEASENO" = "7.3" ] || [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ] || [ "$RELEASENO" = "7.6" ] ; then
          echo -e "OS version check: ${GREEN}[passed]${NC}"
      else
          echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
      fi
   elif [ $OCPMINOR -eq 7 ] || [ $OCPMINOR -eq 6 ] ; then
      if [ "$RELEASENO" = "7.3" ] || [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ] || [ "$RELEASENO" = "7.6" ]; then
          echo -e "OS version check: ${GREEN}[passed]${NC}"
      else
          echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
      fi
     else
        if [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ]  || [ "$RELEASENO" = "7.6" ] ; then
            echo -e "OS version check: ${GREEN}[passed]${NC}"
        else
            echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
        fi
   fi
   fi
   if [ "$RELEASENO" = "$REF_RELEASENO" ]; then
      echo -e " Red Hat release: $RELEASE; uname: $UNAME"
   else
      echo -e " Red Hat release: ${YELLOW}$RELEASE${NC}; uname: $UNAME"
   fi
   
done

echo "NODES"
for node in $NODES
do
   RELEASE=`cat pssa-$node/sosreport*/etc/redhat-release`
   RELEASENO=`echo "$RELEASE" | awk -F " " '{print $7}'`
   UNAME=`cat pssa-$node/sosreport*/uname`
   if [ "$OCPMINOR" = "" ] ; then
      echo -e "OS version check: [skipped] - reason: as no valid OpenShift release was detected ($OCPVERSION) the product seems to be not installed"
   else
   if [ $OCPMINOR -eq 9 ] ; then
      if [ "$RELEASENO" = "7.3" ] || [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ] || [ "$RELEASENO" = "7.6" ] ; then
          echo -e "OS version check: ${GREEN}[passed]${NC}"
      else
          echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
      fi
   elif [ $OCPMINOR -eq 7 ] || [ $OCPMINOR -eq 6 ] ; then
      if [ "$RELEASENO" = "7.3" ] || [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ] || [ "$RELEASENO" = "7.6" ]; then
          echo -e "OS version check: ${GREEN}[passed]${NC}"
      else
          echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
      fi
     else
        if [ "$RELEASENO" = "7.4" ] || [ "$RELEASENO" = "7.5" ]  || [ "$RELEASENO" = "7.6" ] ; then
            echo -e "OS version check: ${GREEN}[passed]${NC}"
        else
            echo -e "OS version check: ${RED}[failed]${NC} - reason: used release $RELEASENO is not supported for OpenShift $OCPVERSION"
        fi
   fi
   fi
    if [ "$RELEASENO" = "$REF_RELEASENO" ]; then
      echo -e " Red Hat release: $RELEASE; uname: $UNAME"
   else
      echo -e " Red Hat release: ${YELLOW}$RELEASE${NC}; uname: $UNAME"
   fi 
done



