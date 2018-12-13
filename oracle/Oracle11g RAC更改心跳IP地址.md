> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 https://yq.aliyun.com/articles/672200

> 数据库版本：11.2.0.4.0

# 主机配置信息

hosts 文件配置：

```
[grid@prod01 ~]$ cat /etc/hosts
#127.0.0.1    localhost.localdomain    localhost.localdomain    localhost4    localhost4.localdomain4
#::1    localhost.localdomain    localhost.localdomain    localhost6    localhost6.localdomain6
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.0.230    prod01
192.168.0.232    prod01-vip

192.168.0.231    prod02
192.168.0.233    prod02-vip
192.168.0.234    scan
```

PROD01 ip 配置：

```
[grid@prod01 ~]$ ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:1e:dd:db brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.230/24 brd 192.168.0.255 scope global eth0
    inet 192.168.0.232/24 brd 192.168.0.255 scope global secondary eth0:1
    inet6 fe80::20c:29ff:fe1e:dddb/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:1e:dd:e5 brd ff:ff:ff:ff:ff:ff
    inet 12.168.0.230/24 brd 12.168.0.255 scope global eth1
    inet 169.254.43.21/16 brd 169.254.255.255 scope global eth1:1
    inet6 fe80::20c:29ff:fe1e:dde5/64 scope link 
       valid_lft forever preferred_lft forever
```

PROD02 ip 配置：

```
[oracle@prod02 ~]$ ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:97:6c:de brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.231/24 brd 192.168.0.255 scope global eth0
    inet 192.168.0.233/24 brd 192.168.0.255 scope global secondary eth0:1
    inet6 fe80::20c:29ff:fe97:6cde/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:1e:dd:e5 brd ff:ff:ff:ff:ff:ff
    inet 12.168.0.231/24 brd 12.168.0.255 scope global eth1
    inet 169.254.70.199/16 brd 169.254.255.255 scope global eth1:1
    inet6 fe80::20c:29ff:fe1e:dde5/64 scope link 
       valid_lft forever preferred_lft forever
```

## 心跳 ip 地址变更信息

prod01 eth1
12.168.0.230/24 =====> 17.17.0.1/24
prod02 eth1
12.168.0.230/24 =====> 17.17.0.2/24

## 备份 ocr，olr，gpnp profile

(2 个节点都需要备份)

olr 备份：
/u01/app/11.2.0/grid/bin/ocrconfig -local -manualbackup
ocr 备份：
/u01/app/11.2.0/grid/bin/ocrconfig -manualbackup

```
[grid@prod01 ~]$ cd /u01/app/11.2.0/grid/gpnp/profiles/peer/
[grid@prod01 peer]$ pwd
/u01/app/11.2.0/grid/gpnp/profiles/peer
[grid@prod01 peer]$ ls -l
total 8
-rw-r--r-- 1 grid oinstall 1823 Oct 26 09:49 profile_orig.xml
-rw-r--r-- 1 grid oinstall 1886 Oct 26 09:56 profile.xml
[grid@prod01 peer]$ cp profile.xml profile.xml.bak

[root@prod01 ~]# /u01/app/11.2.0/grid/bin/ocrconfig -manualbackup
prod02     2018/11/21 09:18:49     /u01/app/11.2.0/grid/cdata/prod-cluster/backup_20181121_091849.ocr
[root@prod01 ~]# /u01/app/11.2.0/grid/bin/ocrconfig -showbackup

prod02     2018/11/21 09:00:45     /u01/app/11.2.0/grid/cdata/prod-cluster/backup00.ocr

prod02     2018/11/21 05:00:45     /u01/app/11.2.0/grid/cdata/prod-cluster/backup01.ocr

prod02     2018/11/21 01:00:44     /u01/app/11.2.0/grid/cdata/prod-cluster/backup02.ocr

prod02     2018/11/20 01:00:42     /u01/app/11.2.0/grid/cdata/prod-cluster/day.ocr

prod02     2018/11/12 21:00:25     /u01/app/11.2.0/grid/cdata/prod-cluster/week.ocr

prod02     2018/11/21 09:18:49     /u01/app/11.2.0/grid/cdata/prod-cluster/backup_20181121_091849.ocr
```

## 更改 grid ip 地址信息：

> 保持所有节点处于运行状态，只要在一个节点操作既可以，用 root 用户执行操作。

```
[root@prod01 ~]# /u01/app/11.2.0/grid/bin/oifcfg iflist
eth0  192.168.0.0
eth1  12.168.0.0
eth1  169.254.0.0

[root@prod01 ~]# /u01/app/11.2.0/grid/bin/oifcfg getif
eth0  192.168.0.0  global  public
eth1  12.168.0.0  global  cluster_interconnect

[root@prod01 ~]# ipcalc -bnm  17.17.0.1 255.255.255.0
NETMASK=255.255.255.0
BROADCAST=17.17.0.255
NETWORK=17.17.0.0

[root@prod01 ~]# /u01/app/11.2.0/grid/bin/oifcfg setif -global eth1/17.17.0.0:cluster_interconnect
[root@prod01 ~]# /u01/app/11.2.0/grid/bin/oifcfg getif
eth0  192.168.0.0  global  public
eth1  12.168.0.0  global  cluster_interconnect
eth1  17.17.0.0  global  cluster_interconnect

```

## 关闭数据库集群软件

```
/u01/app/11.2.0/grid/bin/crsctl stop has
```

## 更改主机心跳 ip 地址，启动数据库集群软件

```
[root@prod01 ~]# ip a s eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:1e:dd:e5 brd ff:ff:ff:ff:ff:ff
    inet 17.17.0.1/24 brd 17.17.0.255 scope global eth1
    inet6 fe80::20c:29ff:fe1e:dde5/64 scope link 
       valid_lft forever preferred_lft forever

[root@prod01 ~]# /u01/app/11.2.0/grid/bin/crsctl start has
[root@prod02 network-scripts]# ip a s eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:97:6c:e8 brd ff:ff:ff:ff:ff:ff
    inet 17.17.0.2/24 brd 17.17.0.255 scope global eth1
    inet6 fe80::20c:29ff:fe97:6ce8/64 scope link 
       valid_lft forever preferred_lft forever
[root@prod02 ~]# /u01/app/11.2.0/grid/bin/crsctl start has
```

## 检查集群软件状态和删除之前信息网络信息：

```
[root@prod01 ~]# /u01/app/11.2.0/grid/bin/crsctl stat res -t
# 确认所有集群启动之后，执行如下操作。
[root@prod01 ~]# /u01/app/11.2.0/grid/bin/oifcfg getif
eth0  192.168.0.0  global  public
eth1  12.168.0.0  global  cluster_interconnect
eth1  17.17.0.0  global  cluster_interconnect

[root@prod01 ~]# /u01/app/11.2.0/grid/bin/oifcfg  delif -global eth1/12.168.0.0

[root@prod01 ~]# /u01/app/11.2.0/grid/bin/oifcfg getif
eth0  192.168.0.0  global  public
eth1  17.17.0.0  global  cluster_interconnect
```

# subnet 计算命令：

这是按照子网掩码 252 计算的网络配置，一会打算使用这个值模拟错误：
[root@prod01 ~]# ipcalc -bnm 17.17.0.1 255.255.255.0
NETMASK=255.255.255.0
BROADCAST=17.17.0.255
NETWORK=17.17.0.0

# 参考手册：

如何修改集群的公网信息（包括 VIP） (文档 ID 1674442.1)
如何在 oracle 集群环境下修改私网信息 (文档 ID 2103317.1)