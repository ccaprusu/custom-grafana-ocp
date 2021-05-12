#!/bin/sh

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version
OCPMINOR=`echo "$OCPVERSION" | awk -F "." '{print $2}'`

IMAGES_REF=` egrep 'etcd|control-plane|console|pod' pssa-${MASTERNODEARR[0]}/sosreport-*/sos_commands/docker/docker_images | awk '{ print $1, $3 }'`

echo "MASTER-NODES"
for master in $MASTERNODES
do

   if ( [[ $OCPMINOR -lt 10 ]] ); then
       echo -e "$master control-plane images test: [not applicable] - reason: OCP $OCPVERSION version in use"
   else

   IMAGES=` egrep 'etcd|control-plane|console|pod' pssa-$master/sosreport-*/sos_commands/docker/docker_images | awk '{ print $1, $3 }'`
   TEST_REF=` echo "$IMAGES_REF" | grep 'etcd' | sort`
   TEST=` echo "$IMAGES" | grep 'etcd' | sort`
   if [[ "$TEST" = "$TEST_REF" ]] ; then
      echo -e "$master ETCD images test: ${GREEN}[passed]${NC}"
   else       
      echo -e "$master ${RED}[failed]${NC} - reason: different images in comparison to ${MASTERNODEARR[0]} - found: \"$TEST\", while expected \"$TEST_REF\""
   fi

   TEST_REF=` echo "$IMAGES_REF" | grep 'control-plane' | sort`
   TEST=` echo "$IMAGES" | grep 'control-plane' | sort`
   if [[ "$TEST" = "$TEST_REF" ]] ; then
      echo -e "$master control-plane images test: ${GREEN}[passed]${NC}"
   else       
      echo -e "$master control-plane images test: ${RED}[failed]${NC} - reason: different images in comparison to ${MASTERNODEARR[0]} - found: \"$TEST\", while expected \"$TEST_REF\""
   fi

   TEST_REF=` echo "$IMAGES_REF" | grep 'ose-console' | sort`
   TEST=` echo "$IMAGES" | grep 'ose-console' | sort`
   if [[ "$TEST" = "$TEST_REF" ]] ; then
      echo -e "$master console images test: ${GREEN}[passed]${NC}"
   else       
      echo -e "$master console images test: ${RED}[failed]${NC} - reason: different images in comparison to ${MASTERNODEARR[0]} - found: \"$TEST\", while expected \"$TEST_REF\""
   fi

   TEST_REF=` echo "$IMAGES_REF" | grep 'ose-web-console' | sort`
   TEST=` echo "$IMAGES" | grep 'ose-web-console' | sort`
   if [[ "$TEST" = "$TEST_REF" ]] ; then
      echo -e "$master web-console images test: ${GREEN}[passed]${NC}"
   else       
      echo -e "$master web-console images test: ${RED}[failed]${NC} - reason: different images in comparison to ${MASTERNODEARR[0]} - found: \"$TEST\", while expected \"$TEST_REF\""
   fi

   TEST_REF=` echo "$IMAGES_REF" | grep 'ose-pod' | sort`
   TEST=` echo "$IMAGES" | grep 'ose-pod' | sort`
   if [[ "$TEST" = "$TEST_REF" ]] ; then
      echo -e "$master ose-pod images test: ${GREEN}[passed]${NC}"
   else       
      echo -e "$master ose-pod images test: ${RED}[failed]${NC} - reason: different images in comparison to ${MASTERNODEARR[0]} - found: \"$TEST\", while expected \"$TEST_REF\""
   fi

   fi
done
