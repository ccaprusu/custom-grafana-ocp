#!/bin/python
# Author: Miguel Blach (Crossvale)
# Description: CPU and MEM usage recollector to csv format.

import requests
import time
import os
from collections import OrderedDict
import csv

def prometheusQuery():
    projects = os.popen("oc get project | egrep -v 'NAME|openshift|kube-|trident|default' | cut -f 1 -d ' ' ").read().split("\n") # Lista
    token = os.popen("oc sa get-token prometheus-k8s -n openshift-monitoring").read()
    url = os.popen("oc get route prometheus-k8s -n openshift-monitoring |grep -v NAME |awk '{print $2}'").read()
    api = 'https://'+str(url).rstrip('\r\n')+'/api/v1/query?'
    head = {'Authorization' : 'Bearer %s ' % token}
    dictList = []
    valueDict = []
    for project in projects:
        #Prometheus queries for namespace usage
        cpuMax2weeks = "sum by (namespace) (max_over_time(namespace_name:container_cpu_usage_seconds_total:sum_rate{namespace=~\""+project+"\"}[2w]) * 1000)"
        cpuAvg2weeks = "sum by (namespace) (avg_over_time(namespace_name:container_cpu_usage_seconds_total:sum_rate{namespace=~\""+project+"\"}[2w]) * 1000)"
        cpuMin2weeks = "sum by (namespace) (min_over_time(namespace_name:container_cpu_usage_seconds_total:sum_rate{namespace=~\""+project+"\"}[2w]) * 1000)"
        memMax2weeks = "sort_desc(max_over_time(namespace:container_memory_usage_bytes:sum{namespace=~\""+project+"\"}[2w]) /1024 /1024)"
        memAvg2weeks = "sort_desc(avg_over_time(namespace:container_memory_usage_bytes:sum{namespace=~\""+project+"\"}[2w])/1024 /1024)"
        memMin2weeks = "sort_desc(min_over_time(namespace:container_memory_usage_bytes:sum{namespace=~\""+project+"\"}[2w])/1024 /1024)"
        creationTimestamp = os.popen("oc get project " + project + " -o json | jq -r '.metadata.creationTimestamp'").read().split("\n")[0].split("T",1)[0]
        quotainproject = os.popen(" oc get resourcequotas --no-headers -n " + project +" | cut -f1 -d ' '").read().split("\n")
        quotaApplied = ''
        for quota in quotainproject:
            if quota == 's-size-quota':
                quotaApplied = 'S-Size'
            elif quota == 'm-size-quota':
                quotaApplied = 'M-Size'
            elif quota == 'l-size-quota':
                quotaApplied = 'L-Size'
            elif quota == 'custom-quota':
                quotaApplied = 'Custom'
            else:
                pass
        dataScraps = [cpuMax2weeks,cpuAvg2weeks,cpuMin2weeks,memMax2weeks,memAvg2weeks,memMin2weeks]
        fieldValue = ["cpuMax2weeks","cpuAvg2weeks","cpuMin2weeks","memMax2weeks","memAvg2weeks","memMin2weeks"]
        dictList.append(OrderedDict({'Namespace' : project}))
        for scrap in zip(fieldValue,dataScraps):
            postReq = requests.get(api, headers=head, params={'query' : scrap[1]})
            queryvalue = str(postReq.json()['data']['result']).split('u')[-1][:-4]
            valueDict.append({"Namespace" : project, "%s" % scrap[0] : "%s" % queryvalue })
        #Creation timestamp of the namespace
        valueDict.append({"Namespace" : project, "created" : "%s" % creationTimestamp  }) #
        fieldValue.append("created") #
        valueDict.append({"Namespace" : project, "quota" : "%s" %quotaApplied })
        fieldValue.append("quota")

        for value in valueDict:
            if value["Namespace"] == project:
                cuales = sorted(value.keys())[1] #
                result = sorted(value.values())[0].lstrip('\'') #
                for field in fieldValue:
                    if field == cuales:
                        conversor = {}
                        conversor.update([('%s' %field, '%s' %result)])
                        dictList[-1].update(conversor)
    return dictList 

def dataOrganizer():
    usageCSV = prometheusQuery()
    print(';'.join(map(str, usageCSV[0].keys())))
    for x in usageCSV:
        csvString = ';'.join(map(str, x.values()))
        print(csvString)


dataOrganizer()