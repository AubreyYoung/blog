## Docker网络设置

**Docker容器互联的几个基本方法**

（1）容器挂载主机目录：-v –volumns-from

（2）容器之间互联: –link

（3）外部访问容器：-p

（4）直接使用宿主机网络

```
  docker run --rm=true --net=host --name=mydb -e MYSQL_ROOT_PASSWORD=123456 mysql
  # 使用以下命令查看容器IP与主机完全一致
  docker exec -it mydb ip addr123
```

（5）容器共用一个IP网络

```
  docker run --rm=true --name=mydb -e MYSQL_ROOT_PASSWORD=123456 mysql
# 创建新容器，指定与已有容器共用IP
  docker run --rm=true --net=container:mydb java ip addr
# 共用IP的两个容器，相互怎么访问？（使用localhost）1234
# 用ubuntu自带工具ifconifg查看网络设置（网桥、接口等）【注意：是ifconfig不是ipconfig!^_^】
  ifconifg  
# 使用ip addr查看网络信息
  ip addr1234
```

## 一、自定义网桥

docker安装时会自动创建docker0虚拟网桥。现在创建自己网桥

```
# 安装网桥工具brctl
sudo apt-get install bridge-utils

#查看网桥设备
sudo brctl show

# 添加网桥
sudo brctl addr br0

# 设置网桥IP
sudo ipconfig br0  192.168.100.1 netmask 255.255.255.0

# docker应用指定的网桥: (1)编辑配置：DOCKER_OPTS="-b=br0"
sudo vim /etc/default/docker
# docker应用指定的网桥: (2)重启docker服务
sudo service docker restart
# 查看docker设置是否应用
ps -ef | grep docker
# 查看docker网络设置是否生效
ipconfig1234567891011121314151617181920
```

## 二、Docker容器互联

docker默认允许容器间互联

重启容器时，ip地址变化，但是如果使用–link连接容器，对应容器IP分配时会更新本容器host引用它的IP（解决容器间互联出现的ip问题时，运行容器指定link）

> 【目标】 
> 1、允许容器间的互联 
> 2、阻止容器间的互联 
> 3、允许部分容器互联

准备用于测试的Dockerfile

```Dockerfile
FROM ubuntu:14.04
RUN apt-get install -y ping
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get install -y curl
EXPOSE 80
CMD /bin/bash1234567
```

构建镜像

```Dockerfile
# 构建镜像
docker build -t "ubuntu14:nginx" .
# 创建容器 cct1
docker run -it --name cct1 ubuntu14:nginx
# 启动nginx
nginx123456
```

### 1、使用link指定链接容器的引用别名（好处是：重启容器IP变化时，别名正常使用）

```sh
# 创建容器时指定链接容器别名
docker run --name cct2 -it --link cct1:webtest ubuntu14 "/bin/bash"
# 容器中访问另外一个容器时，直接使用链接别名
ping webtest

# 查看使用link的改变：(1)用env查看环境变量中增加的“WEBTEST_开头”的几个环境变量
env
# 查看使用link的改变：(2)hosts文件中增加了webtest对应的ip映射
vi /etc/hosts

# 测试：重启docker服务，启动cc1、cct2容器，容器的IP发生变化，在cc2中仍可ping链接别名
sudo service docker restart
sudo docker start cct1 cct2
sudo docker attach cct2
ping webtest123456789101112131415
```

### 2、拒绝容器互联（–link –icc –iptables)

（即使–icc=false也会阻断使用–link建立互联的容器间的访问）

```
# 编辑docker默认配置文件: DOCKER_OPTS="--icc=false"
sudo vi /etc/default/docker
# 重启docker服务
sudo service docker restart
# 检查配置已修改
ps -ef | grep docker
# 启动两个容器
sudo docker start cct1 cct2
# 在cct1容器中ping容器cct2的IP（不可ping通）
sudo ping <cct2-ip>
# 在cct2容器中根据对cct1链接来ping容器cct1（可以ping通）
sudo ping webtest123456789101112
```

### 3、只允许部分容器互联

```
# 编辑docker默认配置：DOCKER_OPTS="--icc=false --iptables=true "
sudo vim /etc/default/docker
# 重启docker服务
sudo service docker restart
--link12345
```

有时iptables会出现问题时，需要清空iptables

```
# 清空iptables
sudo iptables -F
# 重启docker服务
sudo service docker restart
# 查看路由表
sudo iptables -L -n123456
```

### 4、Docker容器与外部网格的连接

（1）Docker的参数–ip-forward可设置是否访问外网(ip-forward默认true,转发流量)

```
# 编辑docker默认配置：DOCKER_OPTS="--ip-forward=true --iptables=true"
sudo vim /etc/default/docker
# 使用系统命令查看设置
sysctl net.ipv4.conifg.all.forwarding1234
```

（2）使用iptables管理网络访问

```
# 使用filter表查看网络访问规则
sudo iptables -t filter -L -n
或
sudo iptables -L -n1234
```

（3）使用-p参数指定容器的开放端口

```
# 指定容器开放的端口
docker run -it -p 80 --name cct3 ubuntu14
# 查看容器映射主机的端口
docker port cct3
# 使用iptables查看规则变化
sudo iptables -L -n123456
```

（4）阻止外部对容器的访问（其它规则查看iptables命令的文档）

```
sudo iptables -I DOCKER -s <src-ip> -d <dest-ip> -p TCP --dport 80 -j DROP1
```

### 5、使用网桥实现跨主机的容器连接

原理:Docker网桥使用与宿主机器相同网段的IP，实现跨主机容器的互联

![docker-bridge](https://img-blog.csdn.net/20160610164230659)

环境: 
Mac OSX + Parallels 
两台Ubuntu 14.04虚拟机 
安装网桥管理工具：apt-get install bridge-utils 
IP地址： 
host1: 10.211.55.3 
host2: 10.211.55.5

注意事项：使用parallels虚拟机，而不是vmware或virtual box的原因在于自动分配IP上不适合或不方便实现

#### （1）新建网桥并配置Docker使用新网桥

修改host1配置文件(host2类同,只修改address后面的ip地址)

```
auto br0
iface br0 inet static
address 10.211.55.3
netmask 255.255.255.0
gateway 10.211.55.1
bridge_ports eth0123456
```

使用ifconfig检查配置

修改Docker配置/etc/default/docker

```
host2:
  -b=br0 --fixed-cidr=10.211.55.64/26
host2:
  -b=br0 --fixed-cidr=10.211.55.128/26
1234
```

检查配置

```
# 检查配置
ps -ef | grep docker12
```

#### （2）容器访问其它主机

在host2的Docker中

```
  # 启动容器
    docker run -it ubuntu /bin/bash
  # ping host1主机
    ping 10.211.55.31234
```

#### （3）跨主机的容器间访问

在host1的Docker中

```
  # 启动容器
    docker run -it ubuntu /bin/bash
  # ping host2的容器IP（ifconfig查看ip）
    ping 10.211.55.1291234
```

【优点】 
配置简单，不依赖第三方软件 
【缺点】 
与主机在相同网段，小心划分IP地址 
需要网段控制权，在生产环境中不易实现 
不容易管理，兼容性差

### 6、使用Open vSwitch实现跨主机容器连接（跨网段）

![weave](https://img-blog.csdn.net/20160610164340764)

```
【环境】
  主机软件：mac OSX + virtualbox + 两台Ubuntu14.04虚拟机
  双网卡: Host-Only & NAT
  安装Open vSwitch: apt-get install openvswitch-switch
  安装网桥管理工具：apt-get install bridge-utils
  IP地址： host1: 192.168.59.103 
            host2: 192.168.59.104
1234567
```

#### （1）建立ovs网桥，并添加gre连接(以下以host1设置为例）

```
 # 在创建网桥前后分别查看ovs信息变化
   sudo ovs-vsctl show
 # 创建ovs网桥obr0
   sudo ovs-vsctl add-br obr0
   sudo ovs-vsctl add-port obr0 gre0
   sudo ovs-vsctl set interface gre0 type=gre options:remote_ip=192.168.59.104123456
```

#### （2）为虚拟网桥添加ovs接口

```
 # 创建网桥br0并建立与obr0连接
   sudo brctl addbr br0
   sudo ifconfig br0 192.168.1.1 netmask 255.255.255.0
   sudo brctl addif br0 obr0
 # 查看网桥信息
   sudo brctl show123456
```

#### （3）配置docker容器虚拟网桥

```
 # 编辑配置文件/etc/default/docker
   -b=br0
 # 重启docker服务
   sudo service docker restart  1234
```

【测试1】测试host1中Docker容器对host2的访问（跨网段）

```
  # host1运行容器
    docker run -it ubuntu /bin/bash
  # 查看容器ip（一般为192.16.1.2）
    ipconfig
  # ping host2主机
    ping 192.168.59.104123456
```

【测试2】按同样方式设置host2主机上的Docker网桥br0、虚拟网桥obr0，注意host2上br0为不同的网段192.168.2.1（区别于host1上的192.168.1.1)，虚拟网桥obr0远程ip指向host1地址192.168.59.103

```
  # 在host2中启动容器，并查看ip地址192.168.2.4（假设）
  # 在host1中ping主机host2中的容器(结果ping不通：原因不同网段无法访问)
    ping 192.168.2.4123
```

#### （5）添加不同Docker容器网段路由

```
 # 查看host1路由信息(在添加路由信息前后查看变化）
   route
 # 向host1添加192.168.2.0/24网段的路由
   sudo ip route add 192.168.2.0/24 via 192.168.59.104 dev eth01234
```

【测试3】

```
  # 在host1容器(192.168.1.2)中再次ping主机host2的容器(192.168.2.4)：访问成功
    ping 192.168.2.4
  # 反过来，在host2容器(192.168.2.4)中ping主机host1的容器(192.168.1.2)，也是成功的
    ping 192.168.1.21234
```

### 7、使用Weave实现跨主机的容器连接

Weave是基于的Docker的一项容器互联技术。

[http://weave.works](http://weave.works/)

<https://github.com/weaveworks/weave#readme>

![Weave](https://img-blog.csdn.net/20160610224541251)

【环境准备】

```
  主机软件：mac OSX + virtualbox + 两台Ubuntu14.04虚拟机
  双网卡: Host-Only & NAT
  IP地址： host1: 192.168.59.103 
            host2: 192.168.59.104
1234
```

【软件安装】在两台机器上安装weave

```
# 下载安装weave
  sudo wget -O /usr/bin/weave https://raw.githubusercontent.com/zettio/weave/master/weave
# 更改weave文件夹模式使其可执行
  sudo chmod a+x /usr/bin/weave
# 启动weave(运行一个weave的容器,使用docker ps -l查看正在运行的weave容器）
  weave launch123456
```

【连接】

```
# 在host2连接host1（192.168.59.103）
  weave launch 192.168.59.103
# 在host2使用weave创建容器(容器id给c2）
  c2=$(weave run 192.168.1.2/24 -it ubuntu /bin/bash)
# 进入容器
  docker attach $c2
# 查看容器中增加了ethwe网络设备（ip是192.168.1.2）
  ifconfig
# 在host1中使用weave启动一个容器wc1（容器的IP是192.168.1.10）
  weave run 192.168.1.10/24 -it --name wc1 ubuntu /bin/bash
# 进入容器wc1
  docker attach wc1
# 在容器wc1可以直接pinghost2上的容器
  ping 192.168.1.21234567891011121314
```

### 8、跨主机容器访问

```
环境：centos
host1:  192.168.18.130
  docker0 172.17.42.1/16
host2:  192.168.18.128
  docker0 172.18.42.1/16
12345
```

#### （1）修改Docker0网络地址（满足上面地址要求）

```
# 编辑配置
  vi /usr/lib/systemd/system/docker.service

ExecStart=/usr/bin/docker daemon --bip=172.18.42.1/16 -H fd:// -H=unix:///var/run/docker.sock
# 重启docker
systemctl daemon-reload
# 查看dockerIP
ip addr12345678
```

#### （2）在主机添加一条连接另一主机的路由

```
 # 在host1上添加
 route add -net 172.18.0.0/16 gw 192.168.18.128
 # 在host2上添加
 route add -net 172.17.0.0/16 gw 192.168.18.130

 # 查看本机路由，检查路由是否添加正确
 ip route1234567
```

#### （3）在主机上启动容器ping另一台主机

```
# 从host1启动容器（保持运行状态）
  docker run --rm=true -it java /bin/bash
# 获取ip地址（假如获取ip是172.17.0.1）
  ip addr1234
```

#### （4）在另一主机上ping本地容器ip

```
 # 在host2上ping一下host1的容器地址
 ping 172.17.0.1
 # 显示结果是：目标主机host1禁止，原因是172.17.0.1不属于host2物理网卡上,防火墙规则导致ping禁止。
 # 解决办法是清空路由表
 iptables -F 
 或
 iptables -t nat -F

 # 再ping 172.17.0.1
```