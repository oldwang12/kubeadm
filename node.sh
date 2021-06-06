modprobe br_netfilter
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/ipv4/ip_forward

# 关联issues https://stackoverflow.com/questions/55767652/kubernetes-master-worker-node-kubeadm-join-issue

# kubeadm reset

kubeadm join 10.23.239.33:6443 --token sxc34d.1bl66fiifzzhbu37 \
	--discovery-token-ca-cert-hash sha256:fdea2b985a99f493ae89e96878b825cf97f0861066ed85ebe4a3c48454621a61

# 报错 The connection to the server localhost:8080 was refused - did you specify the right host or port?
# 从节点需要从master将config拷贝过来
cp /etc/kubernetes/admin.conf ~/.kube/config