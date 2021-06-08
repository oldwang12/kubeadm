# master: 安装docker、kubeadm、kubectl、kubelet、flannel

if (( $# != 1 )); then
  echo -e "\033[31m参数个数有误，请重新输入\033[0m"
  echo -e "\033[31m脚本为安装kubeadm使用，你可以通过参数来选择node节点、master节点\033[0m"
  return 0 
fi
###############
#   docker    #
###############

# 安装依赖包
sudo yum install -y yum-utils

# 鉴于国内网络问题，强烈建议使用国内源，官方源请在注释中查看。
# 执行下面的命令添加 yum 软件源
sudo yum-config-manager \
    --add-repo \
    https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

sudo sed -i 's/download.docker.com/mirrors.aliyun.com\/docker-ce/g' /etc/yum.repos.d/docker-ce.repo

# 官方源
# $ sudo yum-config-manager \
#     --add-repo \
#     https://download.docker.com/linux/centos/docker-ce.repo


# 更新 yum 软件源缓存，并安装 docker-ce
sudo yum install -y docker-ce docker-ce-cli containerd.io

# 测试 Docker 是否安装正确
# docker run --rm hello-world

# 阿里云镜像加速
mkdir -p /etc/docker
cat >/etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://9yepy6z6.mirror.aliyuncs.com"]
}
EOF

# 启动 Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
# sudo systemctl daemon-reload
# sudo systemctl restart docker


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

systemctl start kubelet.service
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
if [ $1 == "master" ]; then
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

elif [ $1 == "node" ]; then
modprobe br_netfilter
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/ipv4/ip_forward

kubeadm join 10.23.239.33:6443 --token enmicf.mfsf34hx54swtrkr \
	--discovery-token-ca-cert-hash sha256:0456ad35df4cbff8d5ca6ced7f34cc21c3ed4e3674989eb2e4545e55ec252f00
fi


# 执行以下命令应用配置。
sudo systemctl daemon-reload

systemctl enable kubelet.service
systemctl restart kubelet.service
systemctl status kubelet.service