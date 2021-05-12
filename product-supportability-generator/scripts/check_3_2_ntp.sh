#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

echo "MASTER NODES"

for master in $MASTERNODES
do
   CLOCK=`$CITELLUS_BASE/citellus.py -v -d WARNING -i clock  pssa-$master/sosreport-*/. | grep clock | sed 's/^.*\(plugins.*\).*$/\1/'`
   CHRONYSTATUS=`echo "$CLOCK" | grep 'clock-1-chrony' | awk -F ":" '{print $2}'`
   NTPSTATUS=`echo "$CLOCK" | grep  -E "clock-1-ntpd|ntp-services" | awk -F ":" '{print $2}'`

   if [[ "$CHRONYSTATUS" =~ "okay" ]] ||  [[ "$NTPSTATUS" =~ "okay" ]] ; then
      if [[ "$CLOCK" =~ "failed" ]]; then
         echo -e "Time check: $master: ${YELLOW}[support limitation]${NC} - reason: ntpd or chrony not well configured/synchronised"
      else
         echo -e "Time check: $master: ${GREEN}[passed]${NC}"
      fi
   else
      echo -e "Time check: $master: ${RED}[failed]${NC} - reason: no active ntpd nor chrony found"
   fi
   echo "Time details:"
   echo "$CLOCK"
done

if [ ! "$ETCDNODES" = "" ] ; then
   echo "EXTERNAL ETCD NODES"
fi

for etcd in $ETCDNODES
do
   CLOCK=`$CITELLUS_BASE/citellus.py -v -d WARNING -i clock  pssa-$etcd/sosreport-*/. | grep clock | sed 's/^.*\(plugins.*\).*$/\1/'`
   CHRONYSTATUS=`echo "$CLOCK" | grep 'clock-1-chrony' | awk -F ":" '{print $2}'`
   NTPSTATUS=`echo "$CLOCK" | grep -E "clock-1-ntpd|ntp-services" | awk -F ":" '{print $2}'`

   if [[ "$CHRONYSTATUS" =~ "okay" ]] ||  [[ "$NTPSTATUS" =~ "okay" ]] ; then
      if [[ "$CLOCK" =~ "failed" ]]; then
         echo -e "Time check: $etcd: ${YELLOW}[support limitation]${NC} - reason: ntpd or chrony not well configured/synchronised"
      else
         echo -e "Time check: $etcd: ${GREEN}[passed]${NC}"
      fi
   else
      echo -e "Time check: $etcd: ${RED}[failed]${NC} - reason: no active ntpd nor chrony found"
   fi
   echo "Time details:"
   echo "$CLOCK"
done

echo "INFRA NODES"
for infra in $INFRANODES
do
   CLOCK=`$CITELLUS_BASE/citellus.py -v -d WARNING -i clock  pssa-$infra/sosreport-*/. | grep clock | sed 's/^.*\(plugins.*\).*$/\1/'`
   CHRONYSTATUS=`echo "$CLOCK" | grep 'clock-1-chrony' | awk -F ":" '{print $2}'`
   NTPSTATUS=`echo "$CLOCK" | grep  -E "clock-1-ntpd|ntp-services" | awk -F ":" '{print $2}'`

   if [[ "$CHRONYSTATUS" =~ "okay" ]] ||  [[ "$NTPSTATUS" =~ "okay" ]] ; then
       if [[ "$CLOCK" =~ "failed" ]]; then
         echo -e "Time check: $infra: ${YELLOW}[support limitation]${NC} - reason: ntpd or chrony not well configured/synchronised"
      else
         echo -e "Time check: $infra: ${GREEN}[passed]${NC}"
      fi
   else
      echo -e "Time check: $infra: ${RED}[failed]${NC} - reason: no active ntpd nor chrony found"
   fi
   echo "Time details:"
   echo "$CLOCK"
done

echo "NODES"
for node in $NODES
do
   CLOCK=`$CITELLUS_BASE/citellus.py -v -d WARNING -i clock  pssa-$node/sosreport-*/. | grep clock | sed 's/^.*\(plugins.*\).*$/\1/'`
   CHRONYSTATUS=`echo "$CLOCK" | grep 'clock-1-chrony' | awk -F ":" '{print $2}'`
   NTPSTATUS=`echo "$CLOCK" | grep  -E "clock-1-ntpd|ntp-services" | awk -F ":" '{print $2}'`

   if [[ "$CHRONYSTATUS" =~ "okay" ]] ||  [[ "$NTPSTATUS" =~ "okay" ]] ; then
      if [[ "$CLOCK" =~ "failed" ]]; then
         echo -e "Time check: $node: ${YELLOW}[support limitation]${NC} - reason: ntpd or chrony not well configured/synchronised"
      else
         echo -e "Time check: $node: ${GREEN}[passed]${NC}"
      fi
   else
      echo -e "Time check: $node: ${RED}[failed]${NC} - reason: no active ntpd nor chrony found"
   fi
   echo "Time details:"
   echo "$CLOCK"
done


