# 关闭 swap 分区
swapoff  -a
sed -ri 's/.*swap.*/#&/' /etc/fstab

# 安装 kubelet kubeadm kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

sudo yum install -y kubelet kubeadm kubectl

# 修改内核的运行参数
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system


###############
# 安装kubectl #
###############

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

# 执行以下命令应用配置。
sudo systemctl daemon-reload

systemctl enable kubelet.service
systemctl start kubelet.service
systemctl status kubelet.service