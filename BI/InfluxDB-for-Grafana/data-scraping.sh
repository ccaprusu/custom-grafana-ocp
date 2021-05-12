#!/bin/bash

# Vars
DATABASE="pushdata"
DBADMIN="admin"
DBPASS="mypass"
INFLUXDB="influxdb.cluster-monitoring.svc.cluster.local" # Set Influxdb host
INFLUXDB_PORT="8086" # Default Influxdb plain text port
MAIL_ALERT_RECEIVER="XXX.XXX.ext@boehringer-ingelheim.com"
TMPFILE=/tmp/data_scraping.swap
HOSTNAME=$(hostname -s)
CONTAINER_ID_LIST=$(docker ps -q)
CLUSTER=$(cat /etc/origin/node/bootstrap.kubeconfig | grep "cluster:" | grep -ve "- cluster" | cut -f 2 -d ':' | cut -f1,2 -d'-' | uniq )

# Data collecting loop
data_collect () {
for i in $CONTAINER_ID_LIST
  do
    # Scrape container info [Values in kB]
    image_name=($(docker inspect $i | jq .[].Name | sed 's/[\/," .=]//g'))
    pod_and_namespace=($(docker inspect $i | jq '.[].Config.Labels | ."io.kubernetes.pod.name", ."io.kubernetes.pod.namespace"'| sed 's/[\/," .=]//g'))
    image_size=($(docker ps --format '{{.Size}}' --filter "id=$i" | awk '{ if ($2 == "MB") print $1 * 1000; else if ($2=="GB") print $1 * 1000000; else if ($2=="kB") print $1; else if ($2=="B") print $1 / 1000 }'))
    ephemeral_storage=($(docker ps --format '{{.Size}}' --filter "id=$i" | awk '{ if ($5 == "MB)") print $1 * 1000; else if ($5=="GB)") print $1 * 1000000; else if ($5=="kB)") print $1; else if ($5=="B)") print $1 / 1000 }'))
    echo "ephemeral_storage_read,hostname=$HOSTNAME,container_id=$i,namespace=${pod_and_namespace[1]},pod_name=${pod_and_namespace[0]},image_name=$image_name image_size_value=$image_size" >> $TMPFILE
    echo "ephemeral_storage_write,hostname=$HOSTNAME,container_id=$i,namespace=${pod_and_namespace[1]},pod_name=${pod_and_namespace[0]},image_name=$image_name ephemeral_storage_used_value=$ephemeral_storage" >> $TMPFILE
done
}

# Loop execution
data_collect

# Data POST to InfluxDB with error evaluation and alert mail notification.
if cat $TMPFILE | curl --resolve -f -i X POST --data-binary @- http://$INFLUXDB:$INFLUXDB_PORT/write?db=$DATABASE -u $DBADMIN:$DBPASS; then
  # Scuccess log exit
  logger -s '[cluster-monitoring] Ephemeral storage data scraping run successfully'
else
  # Fail
  logger -s '[cluster-monitoring] Ephemeral storage data scraping FAIL to run'
  printf "%s\n" "[cluster-monitoring] Ephemeral storage data scraping FAIL to run on $(hostname) on $(date)" | mailx -s "$(echo -e "[cluster-monitoring] Ephemeral storage data scraping FAIL to run")" -r $CLUSTER.`/usr/bin/whoami`.`hostname`@boehringer-ingelheim.com $MAIL_RECEIVER
fi;

# Clean up
rm $TMPFILE
