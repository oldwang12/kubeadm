# kubeadm 安装

## 所有节点安装docker
./docker.sh
./kubeadm.sh

## master
./master.sh
./flannel.sh

## node
./node.sh

## kubelet master 执行命令
 ```
 cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
 ExecStart=/usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --cgroup-driver=cgroupfs --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice
 ```
## 安装指定版本
```sh
yum install kubelet-1.15.2-0 kubeadm-1.15.2-0 kubectl-1.15.2-0

sudo kubeadm init --kubernetes-version=v1.15.2
```
## 常见问题
[isseus](https://github.com/ucloud-lee/kubeadm/blob/master/issues.md)
