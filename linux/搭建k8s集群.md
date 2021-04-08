# 1. 搭建K8s环境平台规划

## 1.1 单master集群

![单master集群](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121241155-1525790695.jpg)

## 1.2 多master集群

![多master集群](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121241473-680545982.jpg)

# 2. 服务器硬件配置要求

​	在开始部署k8s集群之前，服务器需要满足以下条件：

- 1️⃣一台或多台服务器，操作系统CentOS 7.x-86_x64。
- 2️⃣硬盘配置：内存2GB或更多，CPU 2核或更多，硬盘30GB或更多。
- 3️⃣集群中的所有机器之间网络互通。
- 4️⃣可以访问外网，需要拉取镜像。
- 5️⃣禁止swap分区。

# 3. 搭建k8s集群部署方式

​	目前生产部署k8s集群主要有两种方式：

- 1️⃣kubeadm：

  - kubeadm是一个k8s部署工具，提供kubeadmin init和kubeadm join，用于快速部署k8s集群。
  - [官网地址](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)。

- 2️⃣二级制包：

  - 从GitHub下载发行版的二进制包，手动部署每个组件，组成k8s集群。

kubeadm降低部署门槛，但是屏蔽了很多细节，遇到问题很难排查。如果想要更容易可控，推荐使用二级制包部署k8s集群，虽然手动部署麻烦点，期间可以学习很多工作原理，也有利于后期维护。

# 4.kubeadm搭建k8s集群

## 4.1 概述

​	kubeadm是官方社区推出的一个用于快速部署k8s集群的工具，这个工具能通过两个命令完成一个k8s集群的部署。

- 1️⃣创建master节点：

```shell
kubeadm init
```

- 2️⃣将Node节点加入到当前集群中：

```shell
kubeadm join <master节点的IP和端口>
```

## 4.2 准备环境

[![img](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121241687-1927905796.jpg)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121241687-1927905796.jpg)

| 角色       | IP              |
| ---------- | --------------- |
| k8s-master | 192.168.217.100 |
| k8s-node1  | 192.168.217.101 |
| k8s-node2  | 192.168.217.102 |

## 4.3 系统初始化

### 4.3.1 关闭防火墙

- 关闭防火墙：

```shell
systemctl stop firewalld
```

- 禁止防火墙开机自启：

```shell
systemctl disable firewalld
```

### 4.3.2 关闭selinux

- 永久关闭：

```shell
# 永久
sed -i 's/enforcing/disabled/' /etc/selinux/config
# 重启
reboot
```

- 临时关闭：

```shell
 # 临时
setenforce 0
```

### 4.3.3 关闭swap分区

- 永久关闭swap分区：

```shell
# 永久
sed -ri 's/.*swap.*/#&/' /etc/fstab
# 重启
reboot
```

- 临时关闭swap分区：

```shell
swapoff -a
```

### 4.3.4 主机名

- 设置主机名：

```shell
hostnamectl set-hostname <hostname>
```

- 设置192.168.217.100的主机名：

```shell
hostnamectl set-hostname k8s-master
```

- 设置192.168.217.101的主机名：

```shell
hostnamectl set-hostname k8s-node1
```

- 设置192.168.217.102的主机名：

```shell
hostnamectl set-hostname k8s-node2
```

### 4.3.5 在master节点上添加hosts

- 在每个节点添加hosts：

```shell
cat >> /etc/hosts << EOF
192.168.217.100 k8s-master
192.168.217.101 k8s-node1
192.168.217.102 k8s-node2
EOF
```

### 4.3.6 将桥接的IPv4流量传递到iptables的链[#](https://www.cnblogs.com/xuweiweiwoaini/p/13884112.html#436-将桥接的ipv4流量传递到iptables的链)

- 在每个节点添加如下的命令：

```shell
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness = 0
EOF
# 加载br_netfilter模块
modprobe br_netfilter
# 查看是否加载
lsmod | grep br_netfilter
# 生效
sysctl --system  
```

### 4.3.7 时间同步

- 在每个节点添加时间同步：

```shell
yum install ntpdate -y
ntpdate time.windows.com
```

### 4.3.8 开启ipvs

- 在每个节点安装ipset和ipvsadm：

```shell
yum -y install ipset ipvsadm
```

- 在所有节点执行如下脚本：

```shell
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
```

- 授权、运行、检查是否加载：

```shell
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
```

- 检查是否加载：

```shell
lsmod | grep -e ipvs -e nf_conntrack_ipv4
```

## 4.4 所有节点安装Docker/kubeadm/kubelet/kubectl

### 4.4.1 概述

- k8s默认CRI（容器运行时）为Docker，因此需要先安装Docker。

### 4.4.2 安装Docker

- 安装Docker：

```shell
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
yum -y install docker-ce-18.06.3.ce-3.el7
systemctl enable docker && systemctl start docker
docker version
```

- 设置Docker镜像加速器：

```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "exec-opts": ["native.cgroupdriver=systemd"],	
  "registry-mirrors": ["https://b9pmyelo.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 4.4.3 添加阿里云的YUM软件源

```shell
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

### 4.4.4 安装kubeadm、kubelet和kubectl

- 由于版本更新频繁，这里指定版本号部署：

```shell
yum install -y kubelet-1.18.0 kubeadm-1.18.0 kubectl-1.18.0
```

- 为了实现Docker使用的cgroup drvier和kubelet使用的cgroup drver一致，建议修改"/etc/sysconfig/kubelet"文件的内容：

```shell
vim /etc/sysconfig/kubelet
# 修改
KUBELET_EXTRA_ARGS="--cgroup-driver=systemd"
```

- 设置为开机自启动即可，由于没有生成配置文件，集群初始化后自动启动：

```shell
systemctl enable kubelet
```

## 4.5 部署k8s的Master节点

- 部署k8s的Master节点(192.168.217.100)：

```shell
# 由于默认拉取镜像地址k8s.gcr.io国内无法访问，这里需要指定阿里云镜像仓库地址
kubeadm init \
  --apiserver-advertise-address=192.168.217.100 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.18.0 \
  --service-cidr=10.96.0.0/12 \
  --pod-network-cidr=10.244.0.0/16
```

[![部署k8s的Master节点](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121241851-153602148.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121241851-153602148.png)

- 根据提示信息，在Master节点上使用kubectl工具：

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

[![根据提示信息，在Master节点上使用kubectl工具](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121242066-733200847.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121242066-733200847.png)

## 4.6 添加k8s的Node节点

- 在192.168.217.101和192.168.217.102上添加如下的命令：

```shell
# 向k8s集群中添加Node节点
kubeadm join 192.168.217.100:6443 --token 4016im.eg4e10yamcbxjm59 \
    --discovery-token-ca-cert-hash sha256:ce2111ce594e5189255144a72268250e5eedda87470cc3a1f69f8c973927699e
```

[![添加k8s的Node节点](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121242274-1695630840.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121242274-1695630840.png)

- 默认的token有效期为24小时，当过期之后，该token就不能用了，这时可以使用如下的命令创建token：

```shell
kubeadm token create --print-join-command
# 生成一个永不过期的token
kubeadm token create --ttl 0
```

## 4.7 部署CNI网络插件

- 根据提示，在Master节点使用kubectl工具查看节点状态：

```shell
kubectl get nodes
```

[![根据提示，在Master节点使用kubectl工具查看节点](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121242435-37741854.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121242435-37741854.png)

- 在Master节点部署CNI网络插件(可能会失败，如果失败，请下载到本地，然后安装)：

```shell
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

[![在Master节点部署CNI网络插件](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121242660-509987373.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121242660-509987373.png)

- 查看部署CNI网络插件进度：

```shell
kubectl get pods -n kube-system
```

[![查看部署CNI网络插件进度](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121242826-406886257.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121242826-406886257.png)

- 再次在Master节点使用kubectl工具查看节点状态：

```shell
kubectl get nodes
```

[![再次在Master节点使用kubectl工具查看节点](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121243000-2058564133.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121243000-2058564133.png)

- 查看集群健康状态：

```shell
kubectl get cs
```

[![查看集群健康状态命令1](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121243181-1043784943.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121243181-1043784943.png)

```shell
kubectl cluster-info
```

[![查看集群健康状态命令2](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121243369-1942439398.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121243369-1942439398.png)

# 5.二进制包搭建k8s集群

## 5.1 准备环境

| 角色       | IP              | 组件                                                         |
| ---------- | --------------- | ------------------------------------------------------------ |
| k8s-master | 192.168.217.100 | kube-api-server、kube-controller-manager、kube-scheduler、docker、etcd |
| k8s-node1  | 192.168.217.101 | kubelet、kube-proxy、docker、etcd                            |
| k8s-node2  | 192.168.217.102 | kubelet、kube-proxy、docker、etcd                            |

## 5.2 系统初始化

- 和`4.3系统初始化`一样。

## 5.3 部署etcd集群

### 5.3.1 概述

- etcd是一个分布式键值存储系统，kubernetes使用etcd进行数据存储，所以需要先准备一个etcd数据库，为了解决etcd单点故障，应该采用集群方式部署，这里可以使用3台组建集群，可以容忍1台机器故障。

| 节点名称 | IP              |
| -------- | --------------- |
| etcd-1   | 192.168.217.100 |
| etcd-2   | 192.168.217.101 |
| etcd-3   | 192.168.217.102 |

> 注意：为了节省机器，这里和k8s节点机器复用。也可以独立于k8s集群之外部署，只要API Server能连接即可。

### 5.3.2 准备cfssl证书生成工具

- cfssl是一个开源的证书管理工具，使用JSON文件生成证书，相比openssl更方便使用。
- 找任意一台服务器操作，这里使用Master节点。

```shell
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
mv cfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo
```

### 5.3.3 生成etcd证书

- 1️⃣自签证书颁发机构（CA）：

  - 创建工作目录：

  ```shell
  mkdir -pv ~/TLS/{etcd,k8s}
  cd TLS/etcd
  ```

  - 自签CA：

  ```shell
  cat > ca-config.json <<EOF
  {
    "signing": {
      "default": {
        "expiry": "87600h"
      },
      "profiles": {
        "kubernetes": {
           "expiry": "87600h",
           "usages": [
              "signing",
              "key encipherment",
              "server auth",
              "client auth"
          ]
        }
      }
    }
  }
  EOF
  ```

  ```shell
  cat > ca-csr.json <<EOF
  {
      "CN": "kubernetes",
      "key": {
          "algo": "rsa",
          "size": 2048
      },
      "names": [
          {
              "C": "CN",
              "L": "Beijing",
              "ST": "Beijing",
              "O": "k8s",
              "OU": "System"
          }
      ]
  }
  EOF
  ```

  - 生成证书：

  ```shell
  cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
  ```

  - 查看生成证书：

  ```shell
  ls -l *pem
  ```

  [![查看生成的证书](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121243544-1325503823.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121243544-1325503823.png)

- 2️⃣使用自签CA签发etcd的https证书：

  - 创建证书申请文件：

  ```shell
  cat > server-csr.json <<EOF
  {
    "CN": "etcd",
    "hosts": [
      "192.168.217.100",
      "192.168.217.101",
      "192.168.217.102"
    ],
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "Beijing",
        "L": "Beijing",
        "O": "k8s",
        "OU": "System"
      }
    ]
  }
  EOF
  ```

  - 生成证书：

  ```shell
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes server-csr.json | cfssljson -bare server
  ```

  - 查看生成证书：

  ```shell
  ls -l server*pem
  ```

  [![查看自签CA签发etcd的https证书](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121243711-2052771909.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121243711-2052771909.png)

### 5.3.4 从GitHub下载二进制文件

```shell
wget https://github.com/etcd-io/etcd/releases/download/v3.4.9/etcd-v3.4.9-linux-amd64.tar.gz
```

### 5.3.5 部署etcd集群

- 在master节点创建工作目录并解压二进制包：

```shell
mkdir -pv /opt/etcd/{bin,cfg,ssl}
tar -zxvf etcd-v3.4.9-linux-amd64.tar.gz
mv etcd-v3.4.9-linux-amd64/{etcd,etcdctl} /opt/etcd/bin/
```

- 创建etcd配置文件

```shell
cat > /opt/etcd/cfg/etcd.conf << EOF
#[Member] 
ETCD_NAME="etcd-1"  
ETCD_DATA_DIR="/var/lib/etcd/default.etcd" 
ETCD_LISTEN_PEER_URLS="https://192.168.217.100:2380" 
ETCD_LISTEN_CLIENT_URLS="https://192.168.217.100:2379" 

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.217.100:2380" 
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.217.100:2379" 
ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.217.100:2380,etcd-2=https://192.168.217.101:2380,etcd-3=https://192.168.217.102:2380" 
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster" 
ETCD_INITIAL_CLUSTER_STATE="new" 
EOF
```

> - ETCD_NAME：节点名称。
> - ETCD_DATA_DIR：数据目录。
> - ETCD_LISTEN_PEER_URLS：集群通信监听地址。
> - ETCD_LISTEN_CLIENT_URLS：客户端访问监听地址 。
> - ETCD_INITIAL_ADVERTISE_PEER_URLS：集群通告地址。
> - ETCD_ADVERTISE_CLIENT_URLS：客户端通告地址。
> - ETCD_INITIAL_CLUSTER：集群节点地址。
> - ETCD_INITIAL_CLUSTER_TOKEN：集群 Token。
> - ETCD_INITIAL_CLUSTER_STATE：加入集群的当前状态， new 是新集群， existing 表示加入已有集群。

- systemd管理etcd：

```shell
cat > /usr/lib/systemd/system/etcd.service << EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.targcaet
[Service]
Type=notify
EnvironmentFile=/opt/etcd/cfg/etcd.conf
ExecStart=/opt/etcd/bin/etcd \
--cert-file=/opt/etcd/ssl/server.pem \
--key-file=/opt/etcd/ssl/server-key.pem \
--peer-cert-file=/opt/etcd/ssl/server.pem \
--peer-key-file=/opt/etcd/ssl/server-key.pem \
--trusted-ca-file=/opt/etcd/ssl/ca.pem \
--peer-trusted-ca-file=/opt/etcd/ssl/ca.pem \
--logger=zap
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
```

- 拷贝刚才生成的证书：

```shell
cp ~/TLS/etcd/ca*pem ~/TLS/etcd/server*pem /opt/etcd/ssl/
```

- 复制master节点所生成的文件到node节点：

```shell
scp -r /opt/etcd/ root@192.168.217.101:/opt/
scp /usr/lib/systemd/system/etcd.service root@192.168.217.101:/usr/lib/systemd/system/
scp -r /opt/etcd/ root@192.168.217.102:/opt/
scp /usr/lib/systemd/system/etcd.service root@192.168.217.102:/usr/lib/systemd/system/
```

- 修改node节点中etcd.conf配置文件中节点名称和当前服务器的IP：

```shell
vim /opt/etcd/cfg/etcd.conf
#[Member]  
ETCD_NAME="etcd-2"  
ETCD_DATA_DIR="/var/lib/etcd/default.etcd" 
ETCD_LISTEN_PEER_URLS="https://192.168.217.101:2380" 
ETCD_LISTEN_CLIENT_URLS="https://192.168.217.101:2379" 

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.217.101:2380" 
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.217.101:2379" 
ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.217.100:2380,etcd-2=https://192.168.217.101:2380,etcd-3=https://192.168.217.102:2380" 
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new" 
#[Member]  
ETCD_NAME="etcd-3"  
ETCD_DATA_DIR="/var/lib/etcd/default.etcd" 
ETCD_LISTEN_PEER_URLS="https://192.168.217.102:2380" 
ETCD_LISTEN_CLIENT_URLS="https://192.168.217.102:2379" 

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.217.102:2380" 
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.217.102:2379" 
ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.217.100:2380,etcd-2=https://192.168.217.101:2380,etcd-3=https://192.168.217.102:2380" 
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster" 
ETCD_INITIAL_CLUSTER_STATE="new" 
```

- 每个节点启动并设置开机启动：

```shell
systemctl daemon-reload
systemctl start etcd
systemctl enable etcd
```

- 每个节点查看集群状态：

```shell
systemctl status etcd.service
```

## 5.4 为ApI Server自签证书

- 1️⃣自签证书颁发机构（CA）：

  - 进入工作目录：

  ```shell
  cd ~/TLS/k8s/
  ```

  - 自签CA：

  ```shell
  cat > ca-config.json <<EOF
  {
    "signing": {
      "default": {
        "expiry": "87600h"
      },
      "profiles": {
        "kubernetes": {
           "expiry": "87600h",
           "usages": [
              "signing",
              "key encipherment",
              "server auth",
              "client auth"
          ]
        }
      }
    }
  }
  EOF
  ```

  ```shell
  cat > ca-csr.json <<EOF
  {
      "CN": "kubernetes",
      "key": {
          "algo": "rsa",
          "size": 2048
      },
      "names": [
          {
              "C": "CN",
              "L": "Beijing",
              "ST": "Beijing",
              "O": "k8s",
              "OU": "System"
          }
      ]
  }
  EOF
  ```

  - 生成证书：

  ```shell
  cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
  ```

  - 查看生成的证书：

  ```shell
  ll *pem
  ```

- 2️⃣使用自签CA签发etcd的https证书：

  - 创建证书申请文件：

  ```shell
  cat > kube-proxy-csr.json << EOF
  {
    "CN": "system:kube-proxy",
    "hosts": [],
    "key": {
      "algo": "rsa",
      "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "L": "BeiJing",
        "ST": "BeiJing",
        "O": "k8s",
        "OU": "System"
      }
    ]
  }
  EOF
  ```

  ```shell
  cat > server-csr.json<< EOF
  {
      "CN": "kubernetes",
      "hosts": [
        "10.0.0.1",
        "127.0.0.1",
        "kubernetes",
        "kubernetes.default",
        "kubernetes.default.svc",
        "kubernetes.default.svc.cluster",
        "kubernetes.default.svc.cluster.local",
        "192.168.217.100",
        "192.168.217.101",
        "192.168.217.102",
        "192.168.217.1",
        "192.168.217.2",
        "192.168.31.198"
      ],
      "key": {
          "algo": "rsa",
          "size": 2048
      },
      "names": [
          {
              "C": "CN",
              "L": "BeiJing",
              "ST": "BeiJing",
              "O": "k8s",
              "OU": "System"
          }
      ]
  }
  EOF
  ```

  - 生成证书：

  ```shell
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes server-csr.json | cfssljson -bare server
  ```

  ```shell
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
  ```

## 5.5 部署Master组件

### 5.5.1 查看GitHub上的地址

- [查看地址](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#v1183)。

### 5.5.2 下载并解压二进制包

```shell
mkdir -pv /opt/kubernetes/{bin,cfg,ssl,logs}
wget "https://dl.k8s.io/v1.18.10/kubernetes-server-linux-amd64.tar.gz"
tar -zxvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin
cp kube-apiserver kube-scheduler kube-controller-manager /opt/kubernetes/bin
cp kubectl /usr/bin/
```

### 5.5.3 部署kube-apiserver

- 创建配置文件：

```shell
cat > /opt/kubernetes/cfg/kube-apiserver.conf << EOF
KUBE_APISERVER_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--etcd-servers=https://192.168.217.100:2379,https://192.168.217.101:2379,https://192.168.217.102:2379 \\
--bind-address=192.168.217.100 \\
--secure-port=6443 \\
--advertise-address=192.168.217.100 \\
--allow-privileged=true \\
--service-cluster-ip-range=10.0.0.0/24 \\
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction \\
--authorization-mode=RBAC,Node \\
--enable-bootstrap-token-auth=true \\
--token-auth-file=/opt/kubernetes/cfg/token.csv \\
--service-node-port-range=30000-32767 \\
--kubelet-client-certificate=/opt/kubernetes/ssl/server.pem \\
--kubelet-client-key=/opt/kubernetes/ssl/server-key.pem \\
--tls-cert-file=/opt/kubernetes/ssl/server.pem \\
--tls-private-key-file=/opt/kubernetes/ssl/server-key.pem \\
--client-ca-file=/opt/kubernetes/ssl/ca.pem \\
--service-account-key-file=/opt/kubernetes/ssl/ca-key.pem \\
--etcd-cafile=/opt/etcd/ssl/ca.pem \\
--etcd-certfile=/opt/etcd/ssl/server.pem \\
--etcd-keyfile=/opt/etcd/ssl/server-key.pem \\
--audit-log-maxage=30 \\
--audit-log-maxbackup=3 \\
--audit-log-maxsize=100 \\
--audit-log-path=/opt/kubernetes/logs/k8s-audit.log"
EOF
```

> - --logtostderr：启用日志。
> - --v：日志等级。
> - --log-dir：日志目录。
> - --etcd-servers：etcd集群地址。
> - --bind-address：监听地址。
> - --secure-port：https安全端口。
> - --advertise-address：集群通告地址。
> - --allow-privileged：启用授权。
> - --service-cluster-ip-range：Service虚拟IP地址段。
> - --enable-admission-plugins：准入控制模块。
> - --authorization-mode：认证授权，启用RBAC授权和节点自管理。
> - --enable-bootstrap-token-auth：启用TLS bootstrap机制。
> - --token-auth-file：bootstrap token文件。
> - --service-node-port-range：Sevice nodeport类型默认分配端口范围。
> - --kubelet-client-xxx：apiserver访问kubelet客户端整数。
> - --tls-xxx-file：apiserver https证书。
> - --etcd-xxxfile：连接etcd集群证书。
> - --audit-log-xxx：审计日志。

- 复制刚才生成的文件到配置文件所在路径：

```shell
cp ~/TLS/k8s/ca*pem ~/TLS/k8s/server*pem ~/TLS/k8s/kube-proxy*pem /opt/kubernetes/ssl/
```

### 5.5.4 启用TLS Bootstrapping机制

- Master上的apiserver启用TLS认证后，Node节点kubelet和kube-proxy要和kube-apiserver进行通信，必须使用CA签发的有效整数才可以，当Node节点很多的时候，这种客户端证书颁发需要大量工作，同样也会增加集群扩展复杂度。为了简化操作流程，k8s引入了TLS Bootstrapping机制来自动颁发客户端证书，kubelet会以一个低权限用户向apiserver申请证书，kubelet的证书由apiserver动态签署。
- 制作token令牌：

```shell
head -c 16 /dev/urandom | od -An -t x | tr -d ' '
```

- 创建token文件：

```shell
cat > /opt/kubernetes/cfg/token.csv << EOF
6cd622a46af13091337d98f0ac9da4d0,kubelet-bootstrap,10001,"system:nodebootstrapper"
EOF
```

### 5.5.5 systemd管理apiserver

```shell
cat > /usr/lib/systemd/system/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kube-apiserver.conf
ExecStart=/opt/kubernetes/bin/kube-apiserver \$KUBE_APISERVER_OPTS
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
```

### 5.5.6 启动apiserver并设置开机启动

```shell
systemctl daemon-reload
systemctl start kube-apiserver
systemctl enable kube-apiserver
```

### 5.5.7 部署kube-controller-manager[

- 创建配置文件：

```shell
cat > /opt/kubernetes/cfg/kube-controller-manager.conf << EOF
KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--leader-elect=true \\
--master=127.0.0.1:8080 \\
--bind-address=127.0.0.1 \\
--allocate-node-cidrs=true \\
--cluster-cidr=10.244.0.0/16 \\
--service-cluster-ip-range=10.0.0.0/24 \\
--cluster-signing-cert-file=/opt/kubernetes/ssl/ca.pem \\
--cluster-signing-key-file=/opt/kubernetes/ssl/ca-key.pem \\
--root-ca-file=/opt/kubernetes/ssl/ca.pem \\
--service-account-private-key-file=/opt/kubernetes/ssl/ca-key.pem \\
--experimental-cluster-signing-duration=87600h0m0s"
EOF
```

> - --master：通过本地非安全本地端口8080连接apiserver。
> - --leader-elect：当该组件启动多个的时候，自动选举。
> - --cluster-signing-cert-file和--cluster-signing-key-file：自动为kubelet颁发证书的CA，和apiserver保持一致。

### 5.5.8 systemd管理controller-manager

```shell
cat > /usr/lib/systemd/system/kube-controller-manager.service << EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=/opt/kubernetes/cfg/kube-controller-manager.conf
ExecStart=/opt/kubernetes/bin/kube-controller-manager \$KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

### 5.5.9 启动controller-manager并设置开机启动

```shell
systemctl daemon-reload
systemctl start kube-controller-manager
systemctl enable kube-controller-manager
```

### 5.5.10 部署kube-scheduler

- 创建配置文件：

```shell
cat > /opt/kubernetes/cfg/kube-scheduler.conf << EOF
KUBE_SCHEDULER_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--leader-elect=true \\\
--master=127.0.0.1:8080 \\
--bind-address=127.0.0.1"
EOF
```

> - --master：通过本地非安全本地端口 8080 连接 apiserver。
> - --leader-elect：当该组件启动多个时， 自动选举（ HA） 。

### 5.5.11 systemd管理scheduler

- 创建配置文件：

```shell
cat > /usr/lib/systemd/system/kube-scheduler.service << EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kube-scheduler.conf
ExecStart=/opt/kubernetes/bin/kube-scheduler \$KUBE_SCHEDULER_OPTS
Restart=on-failure 
[Install]
WantedBy=multi-user.target
EOF
```

### 5.5.12 启动scheduler并设置开机启动

```shell
systemctl daemon-reload
systemctl start kube-scheduler
systemctl enable kube-scheduler
```

### 5.5.13 查看集群状态

- 所有组件都已经启动成功，通过kubectl工具查看当前集群的组件状态：

```shell
kubectl get cs
```

[![二进制包手动部署Master组件成功](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121243863-2110247919.png)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121243863-2110247919.png)

## 5.6 Docker安装

- 和`4.4.2安装Docker`步骤一样（每个节点都需要安装Docker）。

## 5.7 部署Node组件

### 5.7.1 在所有Node节点创建工作目录

```shell
mkdir -pv /opt/kubernetes/{bin,cfg,ssl,logs}
```

### 5.7.2 从Master节点拷贝二进制文件

```shell
cd ~/TLS/k8s/kubernetes/server/bin
scp kubelet  kube-proxy root@192.168.217.101:/opt/kubernetes/bin
scp kubelet  kube-proxy root@192.168.217.102:/opt/kubernetes/bin
scp -r /opt/kubernetes/ssl/ root@192.168.217.101:/opt/kubernetes/ssl
scp -r /opt/kubernetes/ssl/ root@192.168.217.102:/opt/kubernetes/ssl
```

### 5.7.3 在Master节点生成bootstrap.kubeconfig和kube-proxy.kubeconfig文件

- 创建配置文件：

```shell
cat > ~/configure.sh << EOF
#! /bin/bash
# create TLS Bootstrapping Token
#----------------
#创建  kubelet bootstrapping 配置文件
export PATH=$PATH:/opt/kubernetes/bin
export KUBE_APISERVER="https://192.168.217.100:6443"
export BOOTSTRAP_TOKEN="6cd622a46af13091337d98f0ac9da4d0"
#创建绑定角色
kubectl create clusterrolebinding kubelet-bootstrap \
  --clusterrole=system:node-bootstrapper \
  --user=kubelet-bootstrap
# 设置 cluster 参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/opt/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=\${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=\${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig

#设置上下文
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig

kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
#-------------
#创建 kube-proxy 配置文件
kubectl config set-cluster kubernetes \
  --certificate-authority=/opt/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=\${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=/opt/kubernetes/ssl/kube-proxy.pem \
  --client-key=/opt/kubernetes/ssl/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

EOF
```

- 执行脚本，并将bootstrap.kubeconfig和kube-proxy.kubeconfig文件复制到所有的Node节点：

```shell
scp bootstrap.kubeconfig  kube-proxy.kubeconfig root@192.168.217.101:/opt/kubernetes/cfg
scp bootstrap.kubeconfig  kube-proxy.kubeconfig root@192.168.217.102:/opt/kubernetes/cfg
```

### 5.7.4 所有Node节点部署kubelet

- 对192.168.217.101节点来说，需要创建如下文件：

```shell
cat > /opt/kubernetes/cfg/kubelet.conf << EOF
KUBELET_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--hostname-override=k8s-node1 \\
--network-plugin=cni \\
--kubeconfig=/opt/kubernetes/cfg/kubelet.kubeconfig \\
--bootstrap-kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig \\
--cert-dir=/opt/kubernetes/ssl \\
--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0"
EOF
```

- 对192.168.217.102节点来说，需要创建如下文件：

```shell
cat > /opt/kubernetes/cfg/kubelet.conf << EOF
KUBELET_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--hostname-override=k8s-node2 \\
--network-plugin=cni \\
--kubeconfig=/opt/kubernetes/cfg/kubelet.kubeconfig \\
--bootstrap-kubeconfig=/opt/kubernetes/cfg/bootstrap.kubeconfig \\
--cert-dir=/opt/kubernetes/ssl \\
--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0"
EOF
```

> - --hostname-override：显示名称，集群中唯一。
> - --network-plugin：启用CNI网络插件。
> - --kubeconfig：用于连接apiserver。
> - --cert-dir：kubelet证书生成目录。
> - --pod-infra-container-image：管理Pod网络容器的镜像。

### 5.7.5 所有Node节点systemd管理kubelet

- 创建配置文件：

```shell
cat > /usr/lib/systemd/system/kubelet.service << EOF
[Unit]
Description=Kubernetes Kubelet
After=docker.service
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kubelet.conf
ExecStart=/opt/kubernetes/bin/kubelet \$KUBELET_OPTS
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
```

### 5.7.6 所有Node节点启动kubelet并设置开机自启[

```shell
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
```

### 5.7.7 为所有Node节点部署kube-proxy

- 对192.168.217.101节点来说，需要创建如下文件：

```shell
cat > /opt/kubernetes/cfg/kube-proxy.conf << EOF
KUBE_PROXY_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--kubeconfig=/opt/kubernetes/cfg/kube-proxy.kubeconfig \\
--hostname-override=k8s-node1" 
EOF
```

- 对192.168.217.102节点来说，需要创建如下文件：

```shell
cat > /opt/kubernetes/cfg/kube-proxy.conf << EOF
KUBE_PROXY_OPTS="--logtostderr=false \\
--v=2 \\
--log-dir=/opt/kubernetes/logs \\
--kubeconfig=/opt/kubernetes/cfg/kube-proxy.kubeconfig \\
--hostname-override=k8s-node2"
EOF
```

### 5.7.8 所有Node节点systemd管理kube-proxy

- 创建配置文件：

```shell
cat > /usr/lib/systemd/system/kube-proxy.service << EOF
[Unit]
Description=Kubernetes Proxy
After=network.target
[Service]
EnvironmentFile=/opt/kubernetes/cfg/kube-proxy.conf
ExecStart=/opt/kubernetes/bin/kube-proxy \$KUBE_PROXY_OPTS
Restart=on-failure
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
```

### 5.7.9 所有Node节点启动kube-proxy并设置开机自启

```shell
systemctl daemon-reload
systemctl enable kube-proxy
systemctl start kube-proxy
```

## 5.8 部署CNI网络插件

- 和`4.7部署CNI网络插件步骤`一样。

## 5.9 在Master批量新Node kubelet证书申请

```shell
kubectl get csr
```

[![kubectl get csr](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121244031-720770964.jpg)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121244031-720770964.jpg)

```shell
kubectl certificate approve <NAME>
```

[![kubectl certificate approve 上面生成的name](D:\Github\blog\linux\搭建k8s集群.assets\1128804-20201027121244250-560506130.jpg)](https://img2020.cnblogs.com/blog/1128804/202010/1128804-20201027121244250-560506130.jpg)