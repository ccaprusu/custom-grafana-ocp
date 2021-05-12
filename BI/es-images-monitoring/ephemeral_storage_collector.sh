#!/bin/bash

# Script variable
Cluster=$(cat /etc/origin/node/bootstrap.kubeconfig | grep "cluster:" | grep -ve "- cluster" | cut -f 2 -d ':' | cut -f1,2 -d'-' | uniq )
MBmaxsize='200'     #in MB
GBmaxsize='1'       #in GB
TMPfile=/tmp/ephemeral_storage_collector.tmp
Node=$(hostname|cut -d '.' -f 1)

# TMPfile check to avoid duplicate data in case of left overs or script be interroupted
if [ -f "$TMPfile" ]; then
    rm $TMPfile
fi

# Arguments option for custom value
while getopts w:i:m option
do
case "${option}"
in
w) MBmaxsize=${OPTARG};;
i) GBmaxsize=${OPTARG};;
esac
done

# Summary of the actual research value and arguments helper
echo
echo "# Report parameter in $Cluster for `hostname` :"
echo "# Images with writable size threshold > $MBmaxsize MB (use -w {MB} for custom value)"
echo "# Images with size > $GBmaxsize GB                      (use -i {GB} for custom value)"
echo

# Gathering Docker infos to be dumped in a tmp file for futher filtering.
docker ps --format '{{.ID}},{{.Size}},{{.Names}}' | sed 's/,/ /g' | grep -v openshift > $TMPfile

# Filtering info
container_id_list_for_images_greater_than_GBmaxsize=$(cat $TMPfile | awk {'print $1 " " $5 " " $6'} | grep "GB)" | awk '{ if ($2 > '$GBmaxsize') print $1}')
container_id_list_for_writable_layer_greater_than_MBmaxsize=$(cat $TMPfile | awk {'print $1 " " $2 " " $3'} | egrep "GB|MB" | awk '{ if ($2 > '$MBmaxsize') print $1; else if ($3=="GB") print $1}')

# Function for start array to put all the data inside
data_collect () {
json_containers_data=''
for container in $1
do
        container_size=$(docker ps --format '{{ .Size}}' --filter "id=$container")
        writable_layer_size=$(echo $container_size | awk '{ if ($2 == "MB")  print $1 / 1000; else if ($2=="GB") print $1 }')
        image_size=$(echo $container_size | awk -v x="$writable_layer_size" '{ print $4 - x}')
        container_image_id=$(docker inspect $container --format '{{.Image}}' | xargs docker inspect --format '{{.RepoDigests}}')
        image_name=$(echo $container_image_id | awk -F "@" '{print $1}' | awk -F "/" '{print $2"/"$3}')
        container_metadata=$(docker inspect $container |jq --arg node "$Node" --arg containerID "$container" --arg writableLayerSize "$writable_layer_size" --arg containerImageId "$container_image_id" --arg imageName "$image_name"  --arg imageSize "$image_size" '.[].Config.Labels | {Node: $node, Namespace: ."io.kubernetes.pod.namespace", Pod: ."io.kubernetes.pod.name", "Container Name": ."io.kubernetes.container.name", "Ephemeral storage size": $writableLayerSize, "Container Image ID": $containerImageId,  Image: $imageName , "Image Size": $imageSize, Author: ."ods.build.source.repo.commit.author", "Container Id": $containerID, "Jenkins Job": ."ods.build.jenkins.job.url", "Repo URL": ."ods.build.source.repo.url", "Repo Branch": ."ods.build.source.repo.branch" }')
        json_containers_data+=$container_metadata
done

# Prints array declared before, as a block, separated by jumpline and horizontal line
printf " ---------------------------------------------------------------------- \n%s\n\n" "${json_containers_data[@]}"

# Write output to a csv file in /tmp directory
echo $json_containers_data | jq -r '[.[]] | @csv' > /tmp/$2
}

# Evaluating if there is data to be sent and logging
if [[ -z $container_id_list_for_writable_layer_greater_than_MBmaxsize ]] && [[ -z $container_id_list_for_images_greater_than_GBmaxsize ]]; then
  logger -s '[ephemeral_storage_collector] No oversized images found. Exiting..'
  exit 1
fi

# Beautifier for the body mail report
body () {
echo "##################################################################"
echo
echo "Images with writable size threshold > $MBmaxsize MB"
echo
data_collect "$container_id_list_for_writable_layer_greater_than_MBmaxsize" "container_id_list_for_writable_layer_greater_than_MBmaxsize.csv"
echo
echo "##################################################################"
echo
echo "Images with size > $GBmaxsize GB"
echo
data_collect "$container_id_list_for_images_greater_than_GBmaxsize" "container_id_list_for_images_greater_than_GBmaxsize.csv"
echo
echo "##################################################################"
echo "Executed on `date`"
}

# Show report
body

# Cleaning tmp file, logging and exit
rm $TMPfile
logger -s '[ephemeral_storage_collector] The report has been executed'
exit 0
