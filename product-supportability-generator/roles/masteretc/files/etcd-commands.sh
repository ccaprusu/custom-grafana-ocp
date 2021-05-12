export PSSA_PATH=/var/tmp/pssa/tmp
source /etc/etcd/etcd.conf
export ETCDCTL_API=3
ETCD_ALL_ENDPOINTS=` etcdctl  --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=$ETCD_TRUSTED_CA_FILE --endpoints=$ETCD_LISTEN_CLIENT_URLS --write-out=fields   member list | awk '/ClientURL/{printf "%s%s",sep,$3; sep=","}'`
etcdctl  --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=$ETCD_TRUSTED_CA_FILE --endpoints=$ETCD_LISTEN_CLIENT_URLS --write-out=table  member list > $PSSA_PATH/$(hostname)_etcd_member.out
etcdctl  --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=$ETCD_TRUSTED_CA_FILE --endpoints=$ETCD_ALL_ENDPOINTS  --write-out=table endpoint status  > $PSSA_PATH/$(hostname)_etcd_endpoints.out
etcdctl  --cert=$ETCD_PEER_CERT_FILE --key=$ETCD_PEER_KEY_FILE --cacert=$ETCD_TRUSTED_CA_FILE --endpoints=$ETCD_ALL_ENDPOINTS endpoint health  > $PSSA_PATH/$(hostname)_etcd_health.out
