###############
#   kubeadm   #
###############

# 关闭 swap 分区
swapoff  -a
sed -ri 's/.*swap.*/#&/' /etc/fstab

# 安装 kubelet kubeadm kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF

# 安装指定版本
sudo yum install -y kubelet kubeadm kubectl
# sudo yum install -y kubelet-1.15.2-0 kubeadm-1.15.2-0 kubectl-1.15.2-0

# 修改内核的运行参数
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

# 这里可能没有kubelet.service.d目录，可以手动创建
cd /etc/systemd/system
mkdir kubelet.service.d
cat > /etc/systemd/system/kubelet.service.d/10-proxy-ipvs.conf <<EOF
# 启用 ipvs 相关内核模块
[Service]
ExecStartPre=-/sbin/modprobe ip_vs
ExecStartPre=-/sbin/modprobe ip_vs_rr
ExecStartPre=-/sbin/modprobe ip_vs_wrr
ExecStartPre=-/sbin/modprobe ip_vs_sh
EOF


###############
#     部署     #
###############

# master
# --pod-network-cidr 10.244.0.0/16 参数与后续 CNI 插件有关，这里以 flannel 为例，若后续部署其他类型的网络插件请更改此参数。
# 执行可能出现错误，例如缺少依赖包，根据提示安装即可。
sudo kubeadm init --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers \
      --pod-network-cidr 10.244.0.0/16 \
      --v 5 \
      --ignore-preflight-errors=all

# 部署 CNI
# 这里以 flannel 为例进行介绍。
# flannel
curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f  kube-flannel.yml


# 使用kubectl访问集群
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

###############
#   flannel   #
###############
curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f  kube-flannel.yml
# 这里注意kube-flannel.yml这个文件里的flannel的镜像是0.11.0，quay.io/coreos/flannel:v0.11.0-amd64

# 执行以下命令应用配置。
sudo systemctl daemon-reload

systemctl enable kubelet.service
systemctl restart kubelet.service
systemctl status kubelet.service
