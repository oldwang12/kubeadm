#### 集群初始化如果遇到问题，可以使用下面的命令进行清理：
```
kubeadm reset
```

#### 查看 kubelet 日志
```
journalctl -xefu kubelet
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