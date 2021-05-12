#!/bin/bash

allprojects=$(oc get projects --no-headers | cut -f1 -d ' ')

for ns in $allprojects
do
        oc get dc -n $ns -o json | jq  -r '(.items[] | [ .metadata.namespace, .metadata.name, .spec.strategy.type]) | @csv '
done

