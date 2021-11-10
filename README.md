# kubeadm 安装

## 所有节点安装docker
```sh
wget https://raw.githubusercontent.com/iamwangxiong/kubeadm/master/deploy/docker.sh
```

## node 加入 master 命令
```
kubeadm token create --print-join-command --ttl 0
```
## kubelet master 执行命令
 ```sh
 cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
 ExecStart=/usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --cgroup-driver=cgroupfs --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice
 ```
## 安装指定版本
```sh
yum install -y kubelet-1.15.2-0 kubeadm-1.15.2-0 kubectl-1.15.2-0

sudo kubeadm init --kubernetes-version=v1.15.2
```
#### 集群初始化如果遇到问题，可以使用下面的命令进行清理：
```
kubeadm reset
```

#### 查看 kubelet 日志
```
journalctl -xefu kubelet
```
#### 查看集群初始化默认的使用的配置
```
kubeadm config print init-defaults
```

#### scheduler、controller-manager  Unhealthy
```
kubectl get cs
NAME                 STATUS      MESSAGE                                                                                     ERROR
scheduler            Unhealthy   Get http://127.0.0.1:10251/healthz: dial tcp 127.0.0.1:10251: connect: connection refused
controller-manager   Unhealthy   Get http://127.0.0.1:10252/healthz: dial tcp 127.0.0.1:10252: connect: connection refused
etcd-0               Healthy     {"health":"true"}
```
出现这种情况，是/etc/kubernetes/manifests下的kube-controller-manager.yaml和kube-scheduler.yaml设置的默认端口是0，在文件中注释掉就可以了

然后三台机器均重启kubelet
```
systemctl restart kubelet.service
```
#### master 节点默认不能运行 pod
如果用 kubeadm 部署一个单节点集群，默认情况下无法使用，请执行以下命令解除限制
```
kubectl taint nodes --all node-role.kubernetes.io/master
```

helm install \
 cert-manager jetstack/cert-manager \
 --namespace cert-manager \
 --set installCRDs=true
