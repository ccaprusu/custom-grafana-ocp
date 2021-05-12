#!/bin/bash


TOKEN=$(oc sa get-token prometheus-k8s -n openshift-monitoring)
ROUTE=$(oc get route prometheus-k8s -n openshift-monitoring |grep -v NAME |awk '{print $2}')
#QUERY='sort_desc(namespace_name:container_cpu_usage_seconds_total:sum_rate)'
API=https://$ROUTE/api/v1/query?query= #$QUERY

CPU_PROJECT_USAGE=CPU_project_usage.csv
MEM_PROJECT_USAGE=MEM_project_usage.csv
CPU_CONTAINER_INFO=CPU_container_info.csv
MEM_CONTAINER_INFO=MEM_container_info.csv

# Initialize CPU_project_usage.csv and MEM_project_usage.csv files

echo '"Project","CPU Usage (cores)"' > $CPU_PROJECT_USAGE
echo '"Project","Memory Usage (Bytes)"' > $MEM_PROJECT_USAGE


# Get namespaces CPU and MEM real usage sorted to a CSV file

QUERY='sort_desc(namespace_name:container_cpu_usage_seconds_total:sum_rate)'
curl -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY} | jq -r '.data.result[] | [ .metric.namespace, .value[1]] | @csv ' >> $CPU_PROJECT_USAGE
QUERY='sort_desc(namespace_name:container_memory_usage_bytes:sum)'
curl -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY} | jq -r '.data.result[] | [ .metric.namespace, .value[1]] | @csv ' >> $MEM_PROJECT_USAGE


# Initialize CPU_container_info.csv and MEM_container_info.csv files

echo '' > $CPU_CONTAINER_INFO
echo '"Project","Pod Name","Container Name","CPU Usage(cores)","CPU Usage(milicores)","CPU Requests(cores)","CPU Requests(milicores)","CPU Limits(cores)","CPU Limits(milicores)"' > $CPU_CONTAINER_INFO
echo '' > $MEM_CONTAINER_INFO
echo '"Project","Pod Name","Container Name","Memory Usage(bytes)","Memory Usage(Mi)","Memory Requests(bytes)","Memory Requests(Mi)","Memory Limits(bytes)","Memory Limits(Mi)"' > $MEM_CONTAINER_INFO


# Get containers CPU and MEM resource usage, requests and limits

for project in $(oc projects -q  | grep -v "kube" | grep -v default | grep -v openshift)
do

        oc get pods -n $project  2> /dev/null |grep NAME &> /dev/null
        if [ $? -eq 0 ]; then

                for POD in $(oc get pods -n $project |grep -v NAME | grep -v '0/1' | awk '{print $1}' )
                do

                        # CPU usage, request and limits queries

                        QUERY=namespace_pod_name_container_name:container_cpu_usage_seconds_total:sum_rate{container_name!=\"POD\",pod_name=\"$POD\"}
                        CURL_CPU_USAGE=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY})
                        CPU_USAGE=$(echo $CURL_CPU_USAGE | jq '[.data.result[] | { namespace: .metric.namespace, pod_name: .metric.pod_name, container_name: .metric.container_name, cpu_usage: .value[1] }]')

                        QUERY=kube_pod_container_resource_requests_cpu_cores{pod=\"$POD\"}
                        CURL_CPU_REQUEST=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY})
                        CPU_REQUEST=$(echo $CURL_CPU_REQUEST | jq '[.data.result[] | {container_name: .metric.container, cpu_request: .value[1] }]')

                        QUERY=kube_pod_container_resource_limits_cpu_cores{pod=\"$POD\"}
                        CURL_CPU_LIMIT=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY})
                        CPU_LIMIT=$(echo $CURL_CPU_LIMIT | jq '[.data.result[] | {container_name: .metric.container, cpu_limit: .value[1] }]')

                        IS_CPU_REQUEST_SET=$(echo $CURL_CPU_REQUEST | jq -r '.data.result[] | [ .value[1]] | @csv ')
                        IS_CPU_LIMIT_SET=$(echo $CURL_CPU_LIMIT | jq -r '.data.result[] | [ .value[1]] | @csv ')


                        # Conditionals to proper CSV formatting, inserting blanks where there is no request or limit defined

                        if    [[ -n $IS_CPU_REQUEST_SET ]] && [[ ! -n $IS_CPU_LIMIT_SET ]]
                        then
                                jq  -r --argjson usage "$CPU_USAGE" --argjson request  "$CPU_REQUEST" -n '$usage + $request | group_by(.container_name)| .[] | .[0] * .[1] | [.namespace, .pod_name, .container_name, .cpu_usage, .cpu_request, ""]| @csv' >> $CPU_CONTAINER_INFO

                        elif  [[ ! -n $IS_CPU_REQUEST_SET ]] && [[ -n $IS_CPU_LIMIT_SET ]]
                        then
                                jq  -r --argjson usage "$CPU_USAGE" --argjson limit  "$CPU_LIMIT" -n '$usage + $limit | group_by(.container_name)| .[] | .[0] * .[1] | [.namespace, .pod_name, .container_name, .cpu_usage, "", .cpu_limit ]| @csv' >> $CPU_CONTAINER_INFO

                        elif  [[ ! -n $IS_CPU_REQUEST_SET ]] && [[ ! -n $IS_CPU_LIMIT_SET ]]
                        then
                               jq  -r --argjson usage "$CPU_USAGE" -n '$usage | .[] | [.namespace, .pod_name, .container_name, .cpu_usage, "", ""] |@csv' >> $CPU_CONTAINER_INFO

                        else jq -r --argjson usage "$CPU_USAGE" --argjson request "$CPU_REQUEST" --argjson limit "$CPU_LIMIT" -n '$usage + $request + $limit | group_by(.container_name)| .[] | .[0] * .[1] * .[2]  | [.namespace, .pod_name, .container_name, .cpu_usage, .cpu_request, .cpu_limit]| @csv' >> $CPU_CONTAINER_INFO
                        fi

                        # Memory usage, request and limits queries

                        QUERY="container_memory_usage_bytes{pod_name=\"$POD\",container_name!=\"POD\",image!=\"\"}"
                        CURL_MEM_USAGE=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY})
                        MEMORY_USAGE=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY} | jq '[.data.result[] | { namespace: .metric.namespace, pod_name: .metric.pod_name, container_name: .metric.container_name, memory_usage: .value[1] }]')

                        QUERY=kube_pod_container_resource_requests_memory_bytes{pod=\"$POD\"}
                        CURL_MEM_REQUEST=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY})
                        MEMORY_REQUEST=$(echo $CURL_MEM_REQUEST | jq '[.data.result[] | {container_name: .metric.container, memory_request: .value[1] }]')

                        QUERY=kube_pod_container_resource_limits_memory_bytes{pod=\"$POD\"}
                        CURL_MEM_LIMIT=$(curl -g -k -H "Authorization: Bearer $TOKEN" ${API}${QUERY})
                        MEMORY_LIMIT=$(echo $CURL_MEM_LIMIT | jq '[.data.result[] | {container_name: .metric.container, memory_limit: .value[1] }]')

                        IS_MEM_REQUEST_SET=$(echo $CURL_MEM_REQUEST | jq -r '.data.result[] | [ .value[1]] | @csv ')
                        IS_MEM_LIMIT_SET=$(echo $CURL_MEM_LIMIT | jq -r '.data.result[] | [ .value[1]] | @csv ')


                        # Conditionals to proper CSV formatting, inserting blanks where there is no request or limit defined

                        if    [[ -n $IS_MEM_REQUEST_SET ]] && [[ ! -n $IS_MEM_LIMIT_SET ]]
                        then
                                jq  -r --argjson usage "$MEMORY_USAGE" --argjson request  "$MEMORY_REQUEST" -n '$usage + $request | group_by(.container_name)| .[] | .[0] * .[1] | [.namespace, .pod_name, .container_name, .memory_usage, .memory_request, ""]| @csv' >> $MEM_CONTAINER_INFO

                        elif  [[ ! -n $IS_MEM_REQUEST_SET ]] && [[ -n $IS_MEM_LIMIT_SET ]]
                        then
                                jq  -r --argjson usage "$MEMORY_USAGE" --argjson limit  "$MEMORY_LIMIT" -n '$usage + $limit | group_by(.container_name)| .[] | .[0] * .[1] | [.namespace, .pod_name, .container_name, .memory_usage, "", .memory_limit]| @csv' >> $MEM_CONTAINER_INFO

                        elif  [[ ! -n $IS_MEM_REQUEST_SET ]] && [[ ! -n $IS_MEM_LIMIT_SET ]]
                        then
                               jq  -r --argjson usage "$MEMORY_USAGE" -n '$usage | .[] | [.namespace, .pod_name, .container_name, .memory_usage, "", "" ] |@csv' >> $MEM_CONTAINER_INFO

                        else jq -r --argjson usage "$MEMORY_USAGE" --argjson request "$MEMORY_REQUEST" --argjson limit "$MEMORY_LIMIT" -n '$usage + $request + $limit | group_by(.container_name)| .[] | .[0] * .[1] * .[2]  | [.namespace, .pod_name, .container_name, .memory_usage, .memory_request, .memory_limit]| @csv' >> $MEM_CONTAINER_INFO
                        fi


                done
        fi
done
