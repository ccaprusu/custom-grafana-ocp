#!/bin/bash
# Author: Miguel Blach (Crossvale)
# Description: This script would patch the rolling dc in a namespace to set maxurge to 0% and maxunavalaible to 100%
#              to simulate a Recreate strategy in a Rolling strategy

NAMESPACE=$1
GETDC=$(oc get dc -n $1 --no-headers | cut -f1 -d ' ')

for x in $GETDC
do
        CHECKSTRAT=$(oc get dc $x -n $NAMESPACE -o json | jq -r '.spec.strategy.type')
        echo "Checking DeploymentConfig $x in project $NAMESPACE"
        if [ "$CHECKSTRAT" == "Rolling" ]
        then
                echo "Candidate found"
                echo "Applying new configuration"
                oc patch dc/$x -n $NAMESPACE -p '[{"op":"replace", "path":"/spec/strategy/rollingParams", "value":{"maxUnavailable": "25%","maxSurge":"25%"}}]' --type json
        else
                echo "Not suitable for Rolling strategy optimization."
        fi
done

