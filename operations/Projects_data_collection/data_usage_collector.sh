#!/bin/bash


TOKEN=$(oc sa get-token prometheus-k8s -n openshift-monitoring)
ROUTE=$(oc get route prometheus-k8s -n openshift-monitoring |grep -v NAME |awk '{print $2}')
#QUERY='sort_desc(namespace_name:container_cpu_usage_seconds_total:sum_rate)'
API=https://$ROUTE/api/v1/query?query= #$QUERY

NAMESPACE_USAGE_FILE=namespace_usage_file.csv


# Initialize CPU_container_info.csv and MEM_container_info.csv files

echo 'CPU,,,,,,,,,Memory,,,,,,,,,
Project,Max CPU Usage (cores),Max CPU Usage(milicores),Avg CPU Usage(cores),Avg CPU Usage(milicores),Min CPU Usage(cores),Min CPU Usage (milicores),T-Shirt Candidate,,Project,Max MEM Usage (bytes),Max MEM Usage (Mbytes),Avg MEM Usage (bytes),Avg MEM Usage (Mbytes),Min MEM Usage(bytes),Min MEM (Mbytes),T-Shirt Candidate,,Check if mismatch' > $NAMESPACE_USAGE_FILE

# Get containers CPU and MEM resource usage, requests and limits

QUERY='sum%20by%20(namespace)%20(max_over_time(namespace_name%3Acontainer_cpu_usage_seconds_total%3Asum_rate%5B2w%5D))&start=1583524470&end=1583535270&step=30'
MAX_CPU_USAGE=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY} | jq '[.data.result[] | { namespace: .metric.namespace, max_cpu_usage: .value[1] }]')

QUERY='sum%20by%20(namespace)%20(min_over_time(namespace_name%3Acontainer_cpu_usage_seconds_total%3Asum_rate%5B2w%5D))&start=1583524470&end=1583535270&step=30'
MIN_CPU_USAGE=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY} | jq '[.data.result[] | { namespace: .metric.namespace, min_cpu_usage: .value[1] }]')

QUERY='sum%20by%20(namespace)%20(avg_over_time(namespace_name%3Acontainer_cpu_usage_seconds_total%3Asum_rate%5B2w%5D))&start=1583524470&end=1583535270&step=30'
AVERAGE_CPU_USAGE=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY} | jq '[.data.result[] | { namespace: .metric.namespace, avg_cpu_usage: .value[1] }]')

QUERY='max_over_time(namespace:container_memory_usage_bytes:sum[2w])'
MAX_MEM_USAGE=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY} | jq '[.data.result[] | { namespace: .metric.namespace, max_mem_usage: .value[1] }]')

QUERY='min_over_time(namespace:container_memory_usage_bytes:sum[2w])'
MIN_MEM_USAGE=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY} | jq '[.data.result[] | { namespace: .metric.namespace, min_mem_usage: .value[1] }]')

QUERY='avg_over_time(namespace:container_memory_usage_bytes:sum[2w])'
AVERAGE_MEM_USAGE=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY} | jq '[.data.result[] | { namespace: .metric.namespace, avg_mem_usage: .value[1] }]')

jq -r --argjson max_cpu_usage "$MAX_CPU_USAGE" --argjson min_cpu_usage "$MIN_CPU_USAGE" --argjson avg_cpu_usage "$AVERAGE_CPU_USAGE" --argjson max_mem_usage "$MAX_MEM_USAGE" --argjson min_mem_usage "$MIN_MEM_USAGE" --argjson avg_mem_usage "$AVERAGE_MEM_USAGE" -n '$max_cpu_usage + $min_cpu_usage + $avg_cpu_usage + $max_mem_usage + $min_mem_usage + $avg_mem_usage | group_by(.namespace)| .[] | .[0] * .[1] * .[2] * .[3] * .[4] * .[5] | [.namespace, .max_cpu_usage, "", .avg_cpu_usage, "", .min_cpu_usage, "", "", "", .namespace, .max_mem_usage, "", .avg_mem_usage, "", .min_mem_usage,  "", "", "", ""]| @csv' | grep -v '"*cd"' | grep -v "kube" | grep -v default | grep -v openshift >> $NAMESPACE_USAGE_FILE
