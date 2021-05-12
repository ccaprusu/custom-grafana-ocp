#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh

ocp_version

CHECKQUOTA=true
CHECKLIMITS=true

if [ -d pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/projects ]; then
   for entry in "pssa-${MASTERNODEARR[0]}/var/tmp/pssa/tmp/projects"/*
   do
      NAME=`head -n1 $entry | awk -F ":" '{print $2}'| sed -r 's/\s+//g'`
      if [[ ( ! "$NAME" =~ "openshift" ) && ( ! "$NAME" =~ "kube" ) ]]; then
         QUOTA=`cat $entry | grep "Quota"`
         if [[ "$QUOTA" =~ "<none>" ]]; then
            LIMITS=`cat $entry | grep "Resource limits"`
            if [[ "$LIMITS" =~ "<none>" ]]; then
               echo -e "quota check: $NAME: ${RED}[failed]${NC} - reason: no quota nor resource limits set."
               CHECKLIMITS=false
            else
               echo -e "quota check: $NAME: ${YELLOW}[support limitation]${NC} - reason: no quota, but resource limits set."
               CHECKQUOTA=false
            fi
         else
            echo -e "quota check: $NAME: ${GREEN}[passed]${NC} - reason: project as a quota set."
         fi
      fi
   done
if [ "$CHECKLIMITS" = false ]; then
   echo -e "${BLUE}Note: if no quota is set there is no limitation on the resources a project can request. This limits the capabilities for capacity management. A quota also forces to have limits on every container, what helps the scheduler to find a matching node and to avoid nodes getting out of resources unexpected.${NC}"
fi
if [ "$CHECKQUOTA" = false ]; then
   echo -e "${BLUE}Note: if no quota is set there is no limitation on the resource a project a request. This limits the capabilities for capacity management. Having at least default resource limits ensures that every container will have limits, what helps the scheduler to find a matching node.${NC}"
fi
else
   echo -e "quota check: [skipped] - reason: required data was not collected"
fi
