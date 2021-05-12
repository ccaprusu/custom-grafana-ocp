#!/bin/bash

dirname="$(dirname "$0")"
. $dirname/env_topology.sh


echo "################################################################################"
echo "#                                                                              #"
echo "#              ${bold}OpenShift Cluster Configuration Quick Check ${normal}                    #"
echo "#                                                                              #"
echo "################################################################################"
echo "${bold}Check 1.1: RHSM status${normal}"
. $dirname/check_1_1_rhsm_status.sh
echo "================================================================================"
echo "${bold}Check 1.2.1: Operating System in use${normal}"
. $dirname/check_1_2_1_which_OS.sh
echo "================================================================================"
echo "${bold}Check 1.2.2: Hypervisor in use${normal}"
echo "-- to be done fully manually - here you'll find data only --"
. $dirname/check_1_2_2_which_HV.sh
echo "================================================================================"
echo "${bold}Check 1.3.x.1: CPU of Nodes${normal}"
. $dirname/check_1_3_1_1_allnodes_cpu.sh
echo "================================================================================"
echo "${bold}Check 1.3.x.2: RAM of Nodes${normal}"
. $dirname/check_1_3_1_2_allnodes_memory.sh
echo "================================================================================"
echo "${bold}Check 1.3.x.3: Disk of Nodes${normal}"
echo "-- to be done fully manually - here you'll find data only --"
. $dirname/check_1_3_1_3_allnodes_disk.sh
echo "================================================================================"
echo "${bold}Check 1.3.1: Docker, K8s, OpenShift releases${normal}"
. $dirname/check_1_3_1_master_hw.sh
echo "================================================================================"
echo "${bold}Check 2.1.1: OpenShift patch-level${normal}"
. $dirname/check_2_1_1_OCP_patch-level.sh
echo "================================================================================"
echo "${bold}Check 2.1.2: Operating System patch-level${normal}"
. $dirname/check_2_1_2_OS_patch-level.sh
echo "================================================================================"
echo "${bold}Check 2.2.1: Scheduler Labels found on Nodes${normal}"
. $dirname/check_2_2_1_node-label.sh
echo "================================================================================"
echo "${bold}Check 2.2.3: odd number of ETCD${normal}"
. $dirname/check_2_2_3_odd_etcd.sh
echo "================================================================================"
echo "${bold}Check 3.1: SELinux enforced${normal}"
. $dirname/check_3_1_selinux.sh
echo "================================================================================"
echo "${bold}Check 3.2: Time synchronized${normal}"
. $dirname/check_3_2_ntp.sh
echo "================================================================================"
echo "${bold}Check 3.3.1: DNS resolv config${normal}"
. $dirname/check_3_3_1_dns_config.sh
echo "================================================================================"
echo "${bold}Check 3.3.2: DNSmask config${normal}"
. $dirname/check_3_3_2_dns_resolv.sh
echo "================================================================================"
echo "${bold}Check 3.4.1: Shared Network${normal}"
. $dirname/check_3_4_1_network.sh
echo "================================================================================"
echo "${bold}Check 3.4.2:Master HA VIP${normal}"
. $dirname/check_3_4_2_master_vip.sh
echo "================================================================================"
echo "${bold}Check 3.4.3: Network Manager enabled${normal}"
. $dirname/check_3_4_3_NM.sh
echo "================================================================================"
echo "${bold}Check 3.5.1: SDN provider supported${normal}"
. $dirname/check_3_5_1_sdn_provider.sh
echo "================================================================================"
echo "${bold}Check 3.5.2: SDN configuration${normal}"
. $dirname/check_3_5_2_sdn_config.sh
echo "================================================================================"
echo "${bold}Check 3.6.1: Master node configuration is sync${normal}"
echo "-- to be done fully manually - here you'll find data only --"
. $dirname/check_3_6_1_master-config_diff.sh
echo "================================================================================"
echo "${bold}Check 3.6.1.2: ETCD listed by nearest distance to Master${normal}"
. $dirname/check_3_6_1_2_etcd-distance.sh
echo "================================================================================"
echo "${bold}Check 3.6.2: Node configuration is sync${normal}"
echo "-- to be done fully manually - here you'll find data only --"
. $dirname/check_3_6_2_node-config_diff.sh
echo "================================================================================"
echo "${bold}Check 3.7.1: ETCD storage${normal}"
. $dirname/check_3_7_1_etcd_storage.sh
echo "================================================================================"
echo "${bold}Check 3.7.2: ETCD health status${normal}"
. $dirname/check_3_7_2_etcd_health.sh
echo "================================================================================"
echo "${bold}Check 3.7.3: ETCD member list${normal}"
. $dirname/check_3_7_3_etcd_members.sh
echo "================================================================================"
echo "${bold}Check 3.7.4: ETCD endpoint list${normal}"
. $dirname/check_3_7_4_etcd_endpoints.sh
echo "================================================================================"
echo "${bold}Check 3.7.5: ETCD leader status${normal}"
. $dirname/check_3_7_5_etcd_leader.sh
echo "================================================================================"
echo "${bold}Check 3.7.6: external ETCD${normal}"
. $dirname/check_3_7_6_external-etcd.sh
echo "================================================================================"
echo "${bold}Check 3.8.1: Registry scaled${normal}"
. $dirname/check_3_8_1_registry_scaled.sh
echo "================================================================================"
echo "${bold}Check 3.8.2: Registry Storage${normal}"
. $dirname/check_3_8_2_registry_storage.sh
echo "================================================================================"
echo "${bold}Check 3.9.1: Logging Storage ${normal}"
. $dirname/check_3_9_1_logging_storage.sh
echo "================================================================================"
echo "${bold}Check 3.10.1: Hawkular Metrics Storage${normal}"
. $dirname/check_3_10_1_metrics_storage.sh
echo "================================================================================"
echo "${bold}Check 3.10.2: Prometheus installed${normal}"
. $dirname/check_3_10_2_prometheus_installed.sh
echo "================================================================================"
echo "${bold}Check 3.10.2: Prometheus Storage${normal}"
. $dirname/check_3_10_2_prometheus_storage.sh
echo "================================================================================"
echo "${bold}Check 3.11.1: Router label${normal}"
. $dirname/check_3_11_1_router_label.sh
echo "================================================================================"
echo "${bold}Check 3.12: Storage common checks${normal}"
. $dirname/check_3_12_storage_common.sh
echo "================================================================================"
echo "${bold}Check 3.12.3: Storage Snapshooting feature${normal}"
. $dirname/check_3_12_3_storage_snapshooting.sh
echo "================================================================================"
echo "${bold}Check 3.12.4: Storage CSI feature${normal}"
. $dirname/check_3_12_4_csi.sh
echo "================================================================================"
echo "${bold}Check 3.12.5: Ephemeral Storage feature${normal}"
. $dirname/check_3_12_5_ephemeral_storage.sh
echo "================================================================================"
echo "${bold}Check 3.12.5.1: OCS version${normal}"
. $dirname/check_3_12_5_1_ocs_version.sh
echo "================================================================================"
echo "${bold}Check 3.12.5.8: OCS volume count${normal}"
. $dirname/check_3_12_5_8_ocs_file_volume_count.sh
echo "================================================================================"
echo "${bold}Check 3.12.9: OCS block volume count${normal}"
. $dirname/check_3_12_5_9_ocs_block_volume_count.sh
echo "================================================================================"
echo "${bold}Check 3.14: Swap disabled${normal}"
. $dirname/check_3_14_swap.sh
echo "================================================================================"
echo "${bold}Check 3.15: Container runtime${normal}"
. $dirname/check_3_15_container_runtime.sh
echo "================================================================================"
echo "${bold}Check 3.16: Kubernetes non-final features${normal}"
echo "-- CAUTION: check incomplete --"
. $dirname/check_3_16_K8s_non-final_features.sh
echo "================================================================================"
echo "${bold}Check 3.17: HugePages enabled${normal}"
. $dirname/check_3_17_hugepages.sh
echo "================================================================================"
echo "${bold}Check 3.18: adm diagnostics results${normal}"
echo "-- to be checked manually, if failed as some warning/error could be by intended system config --"
. $dirname/check_3_18_adm_diagnostics.sh
echo "================================================================================"
echo "${bold}Check 3.18: adm diagnostics NodeCheck results${normal}"
echo "-- to be checked manually, if failed as some warning/error could be by intended system config --"
. $dirname/check_3_18_adm_diagnostics_NodeCheck.sh
echo "================================================================================"
echo "${bold}Check 3.19.1: OLM${normal}"
. $dirname/check_3_19_1_OLM.sh
echo "================================================================================"
echo "${bold}Check 3.19.2: Descheduler${normal}"
. $dirname/check_3_19_2_descheduler.sh
echo "================================================================================"
echo "${bold}Check 3.19.3: Podman${normal}"
. $dirname/check_3_19_3_podman.sh
echo "================================================================================"
echo "${bold}Check 3.19.4: Node Problem Detector${normal}"
. $dirname/check_3_19_4_node_problem_detector.sh
echo "================================================================================"
echo "${bold}Check 3.19.5: Service Mesh${normal}"
. $dirname/check_3_19_5_service_mesh.sh
echo "================================================================================"
echo "${bold}Check 3.20: Available Entropy${normal}"
. $dirname/check_3_20_entropy.sh
echo "================================================================================"
echo "${bold}Check others: iptables active${normal}"
. $dirname/check_others_iptables.sh
echo "================================================================================"
echo "${bold}Check others: cloud provider${normal}"
. $dirname/check_others_cloudprovider.sh
echo "================================================================================"
echo "${bold}Check others: Project Quota${normal}"
. $dirname/check_others_quota.sh
echo "================================================================================"
echo "${bold}Check others: Control-Plane Images${normal}"
. $dirname/check_others_control-plane_images.sh
echo "================================================================================"
echo "${bold}Check others: Images versions match Errata${normal}"
. $dirname/check_others_errata_images_versions.sh
echo "================================================================================"

echo "################################################################################"
