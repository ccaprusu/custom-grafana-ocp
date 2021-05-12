# Grafana template

This template is meant to be used to deploy a custom grafana installation with the following features:
- Includes Admin and End-User dasboards
- Integrates with LDAP
- Requires prometheus endpoint to be already configured.

## Parameters
- GRAFANA_IMAGE: Grafana Image
- NAMESPACE: Custom Grafana Namespace (required) 
- SECURITY_TOKEN: Security Token (required at execution time) 
- PROMETHEUS_DATASOURCE: Prometheus Datasource (required) 
- DS_OPENSHIFT_MONITORING_DATASOURCE: datasource name
- LDAP_HOST: LDAP Host (required) 
- GRAFANA_PV_SIZE: Grafana Persistent Volume Size 
- GRAFANA_ROUTE: Grafana Route (required) 

## Usage

```sh
## define the required parameters in /env/cluster.env file
$ cat cluster.env
NAMESPACE=cluster-monitoring
PROMETHEUS_DATASOURCE=https://prometheus-k8s-openshift-monitoring.example.com
GRAFANA_ROUTE=grafana-cluster-monitoring.example.com
LDAP_HOST=ldap.example.com

## define namespace
export CUSTOM_NAMESPACE="cluster-monitoring"

## create new project
oc new-project $CUSTOM_NAMESPACE --display-name="Cluster Monitoring - Custom Grafana Dashboards"

## create grafana service account
oc create sa grafana -n $CUSTOM_NAMESPACE

## deploy template on the fly especifying cluster.env file and grafana.yaml template
oc process -p SECURITY_TOKEN=$(oc sa get-token grafana -n $CUSTOM_NAMESPACE) --param-file=cluster.env -f template/grafana.yaml | oc apply -f -
```