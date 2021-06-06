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

# 启动 Docker
sudo systemctl enable docker
sudo systemctl start docker

# 测试 Docker 是否安装正确
# docker run --rm hello-world

# 阿里云镜像加速
mkdir -p /etc/docker
cat >/etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://9yepy6z6.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker