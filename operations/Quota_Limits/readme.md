# Resources for Quotas and Limits management in OpenShift environments

We use this place to collect YAML templates and guides to be use in customers environments


## Documentation
- [Limits configuration](https://docs.openshift.com/container-platform/3.11/admin_guide/limits.html)
- [ResourceQuota configuration](https://docs.openshift.com/container-platform/3.11/admin_guide/quota.html)
- [Deployment strategies/ custom strategy](https://docs.openshift.com/container-platform/3.11/dev_guide/deployments/deployment_strategies.html#custom-strategy)
- [Managing Projects/Default templates](https://docs.openshift.com/container-platform/3.11/admin_guide/managing_projects.html)
- [Kubernetes strategies](https://dev.to/cloudskills/kubernetes-deployment-strategy-recreate-3kgn)
- [Kubernetes strategies](https://blog.container-solutions.com/kubernetes-deployment-strategies)

### Prometheus Queries for Analysis

- CPU Usage in a range of time(2weeks)

   - Max CPU usage in the last two weeks:
     - sum by (namespace) (max_over_time(namespace_name:container_cpu_usage_seconds_total:sum_rate[2w]))
   - Min CPU usage in the last two weeks:
     - sum by (namespace) (min_over_time(namespace_name:container_cpu_usage_seconds_total:sum_rate[2w]))
   - Average CPU usage in the last two weeks:
     - sum by (namespace) (avg_over_time(namespace_name:container_cpu_usage_seconds_total:sum_rate[2w]))

- Memory Usage in a range of time(2weeks)
   
   - Max Memory usage in the last two weeks:
     - sort_desc(max_over_time(namespace:container_memory_usage_bytes:sum[2w]))
   - Min Memory usage in the last two weeks:
     - sort_desc(min_over_time(namespace:container_memory_usage_bytes:sum[2w]))
   - Average Memory usage in the last two weeks:
     - sort_desc(avg_over_time(namespace:container_memory_usage_bytes:sum[2w]))
 

### Other queries/commands


## Usage

 - scripts/dc-patcher.sh -> This script is the one that we will use to patch the Rolling, with the params maxUnavailable to 100% and maxSurge to 0%
   USAGE: ./dc-patcher.sh $project
 - scripts/strategy-check.sh -> This script was used in the reporting stage to get the strategies in all the deploymentconfigs on the clusters.

