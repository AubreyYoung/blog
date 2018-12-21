# 硬件、OS及云计算技术讲解
[TOC]





## 前言

​	授人以鱼不如授人以渔

​	本文档、个人技术能力局限性

​	软件、硬件、OS、云计算的庞杂

​	启发性的指导性思想、方法




## 一、软件架构及IT设计思想

### 1. 软件架构

![集群架构](D:\Git\blog\linux\pictures\集群架构图1.png)

大型网站架构演化历程 https://www.hollischuang.com/archives/728 

![集群架构](D:\Git\blog\linux\pictures\集群架构图2.jpg)

==**分层**：应用层、服务层、数据层==

### 2. IT思想

- 万物皆文件

  linux proc文件系统

- 处处皆缓存

  **硬件缓存**：CPU一级、二级缓存，内存、SWAP、硬盘缓存、存储缓存

  ![延时](\Git\blog\linux\pictures\处处皆缓存.png)

  [^注]: 0.3ns约为3.1GHz

  **软件缓存**：MongoDB、Redis、Memcached

  **CDN加速**

  **OS buffer与cache**：

  	buffer负责写、cache负责读

​	buffer : 作为buffer cache的内存，是块设备的读写缓冲区

​	cache: 作为page cache的内存，文件系统的cache

- 需求、目的

  [大型网站架构演化历程]: https://www.hollischuang.com/archives/728

- 分层、劳动分工、线性扩展

  闻道有先后、术业有专攻，让合适的人干合适的自己事

  **分层**：应用层、服务层、数据层

  ![计算机集群](C:\Users\galaxy\Desktop\OS\剪贴板图片 (3).jpg)

- 最小化原则

- 其他

  - 在数据产生的地方进行数据处理

  - 网络与硬盘使用相同的协议：网络与硬盘一样快

- 对比学习：
  - Oracle-MySQL（RC--SS）；RDB--NoSQL
  - Oracle--MySQL--MongoDB（堆表--有序表--cson、json）
  - Linux--Windows

==**SharedNoting Or SharedEverything**==
​    ![SharedNoting Or SharedEverything](D:\Git\blog\linux\pictures\SharedNothingOrSharedEverything.png)


  少看中国人写的技术书，少用百度、搜狗、360，别安装360、腾讯管家。

 **杂谈：**

​	 拥抱新技术：关宁铁骑

 	 CAP

​		一致性（Consistency）
​		可用性（Availability）
​		分区容错性（Partition tolerance）

​	BASE

​	基本可用（Basically Available）、软状态（ Soft State）、最终一致性（ Eventual Consistency）

  	贪多嚼不烂  -- 广博未必精通，精通必定广博

**参考文档**：

- 大型网站技术架构：核心原理与案例分析
- 人月神话（40周年中文纪念版）

## 二、硬件、OS

### 整体架构图

![1544065753942](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065753942.png)

### 1. 硬件

#### 1.1 服务器

##### 服务器分类

x86、小机、大型机、云主机-->服务器、云主机

![x86](D:\Git\blog\linux\pictures\x86前视图.png)

![x86](D:\Git\blog\linux\pictures\x86后视图.png)

![](D:\Git\blog\linux\pictures\机柜后视图.JPG)

**服务器安装软件**

​	zabbix、bmc patrol

​	SaltStack、ansible、puppet--堡垒机

​	NBU、commvault

#### 1.2 光纤交换机

##### 配置流程

![光纤交换机](D:\Git\blog\linux\pictures\光纤交换机配置.png)

#####  光纤交换机配置

光纤网关、光闸的区别

![光纤交换机1](D:\Git\blog\linux\pictures\光纤交换机1.png)
![光纤交换机1](D:\Git\blog\linux\pictures\光纤交换机2.png)
![光纤交换机1](D:\Git\blog\linux\pictures\光纤交换机3.png)

**光纤交换机堆叠**

通过XPAK端口将多台光纤交换机相连，称为光纤交换机的“堆叠”。

采用堆叠方式进行连接时，您需要额外购买堆叠线缆，且堆叠长度有限，堆叠线缆最长为2m；但相对于级联，堆叠具有更高的带宽，且不占用光纤交换机的FC端口。

2台光纤交换机进行堆叠的建议组网如
![img](http://download.huawei.com/mdl/imgDownload?uuid=b4065b570c6940fa82085da22c384e61.png)

3台光纤交换机进行堆叠的建议组网如
![img](http://download.huawei.com/mdl/imgDownload?uuid=6f7af80241c943bc8db6fa041e7ce2df.png)

**光纤交换机级联**

通过任意激活的FC端口将多台光纤交换机相连，称为光纤交换机的“级联”。

采用级联方式进行连接时，光纤交换机部分FC端口将被占用；但相对于堆叠，级联采用的光纤具有更长走线距离。

2台光纤交换机进行级联的建议组网如
![img](http://download.huawei.com/mdl/imgDownload?uuid=7a254af29ca9421c87b53cb3a534ec24.png)

3台光纤交换机进行级联
![img](http://download.huawei.com/mdl/imgDownload?uuid=742b8d51f998402d9c8dcbf97b0e525e.png)

#### 1.3 存储

##### 硬盘

SATA --> SAS -->SSD

##### 存储配置

​	B-S 				C-S

![](D:\Git\blog\linux\pictures\存储.png)

![存储前视图](C:\Users\galaxy\Desktop\OS\2017-07-27_165628.png)
![存储后视图](C:\Users\galaxy\Desktop\OS\2017-07-27_170313.png)

![](D:\Git\blog\linux\pictures\iscsi线.png)

![连接存储](C:\Users\galaxy\Desktop\OS\2017-07-27_170118.png)

![1544065631928](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065631928.png)

![1544065473633](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065473633.png)

![1544065506358](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065506358.png)

![1544065525401](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065525401.png)

![1544065579958](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065579958.png)

![1544065561364](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065561364.png)

![1544065600799](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544065600799.png)

![存储监控视图](C:\Users\galaxy\Desktop\OS\2017-07-27_170425.png)

##### 虚拟存储

![1544080198278](C:\Users\galaxy\AppData\Roaming\Typora\typora-user-images\1544080198278.png)

#### 1.4 网络交换机

二层交换机：没有路由功能

三层交换机：路由功能、地址转发

![](D:\Git\blog\linux\pictures\核心交换机.png)

### 2.OS

#### 2.1 OS分类

| Linux  |        |        |                 |
| ------ | ------ | ------ | --------------- |
| Redhat | CentOS | Fedora | *Oracle  Linux* |
| Debian | SuSE   | Ubuntu |                 |

| Unix  |                 |
| ----- | --------------- |
| Aix   | ==Power Linux== |
| HP-UX |                 |

#### 2.2 OS知识点

linux目录结构

![img](http://img1.51cto.com/attachment/201309/230817424.jpg)

**内存、CPU、磁盘IO、网络**

![CPU](D:\Git\blog\linux\pictures\CPU.png)

CPU亲和度：CPU0、CPU1

[Linux性能优化实战]: https://time.geekbang.org/column/intro/140	"Linux性能优化实战"

#### 2.3 命令参数

```
umount -lf  /mnt
mount |column -t
ls -lrt
ps -elf
netstat -lntup
ss -lntup
!export
cd $_
echo $?
iostat -x 1 10
statue
yum provides/yum whatprovide
;; && ||
>/dev/null 2>＆1
fuse -- tasklist /m shell32.dll
ctrl+z --> jobs -->bg %1 --> fg %1
lsof
strace、ltrace
sync
sh -x 
```

#### 2.4 知识点

开源协议：

![开源许可证](./pictures/开源协议.png)

[优雅玩转Vim]: https://www.imooc.com/learn/1049	"优雅玩转Vim"

#### 2.5 常用资源、办公效率提升

SecretCRT、Vmware、Notepad++/UE

Typora/Atom

[Markdown教程-Typora]: https://ke.qq.com/course/204170	"Markdown教程-Typora"
[Atom编辑器]: https://ke.qq.com/course/306649	"web开发神器之炫酷的阿童木(Atom)编辑器"

**Git/GitHub Desktop/SourceTree**

[Git入门]: https://www.imooc.com/learn/1052	"Git入门"
[版本控制入门 – 搬进 Github]: https://www.imooc.com/learn/390	"版本控制入门 – 搬进 Github"
[版本管理工具介绍—Git篇]: https://www.imooc.com/learn/208

Chrome

Windows

[快乐的sublime编辑器]: https://www.imooc.com/learn/333	"快乐的sublime编辑器"

**参考文档**：

- [Linux性能调优指南]: https://legacy.gitbook.com/book/lihz1990/transoflptg/details

- 性能之巅 洞悉系统、企业与云计算

- ==[Linux性能优化实战]: https://time.geekbang.org/column/intro/140	"Linux性能优化实战"==

- 实战LINUX_SHELL编程与服务器管理


## 三、云计算

### 1. 云计算概念

计算资源像电一样自由随需获取：弹性扩展、按需获取

![资源使用](D:\Git\blog\linux\pictures\资源监控.png)

云计算底层技术：

- cgroup
- namespace
- chroot 
- cpu 指令集

### 2. 云计算技术

#### 2.1 docker

docker --> kubernotes(k8s)

![docker](D:\Git\blog\linux\pictures\docker.png)

![kubernotes架构图](D:\Git\blog\linux\pictures\kubernotes.jpg)

#### 2.2 openstack

AWS --> OpenStack/OpenCloud

OS虚拟化、网络虚拟化、存储虚拟化

![openstack](D:\Git\blog\linux\pictures\openstack2)

#### 2.3 VMware vSphere

私有云

### 3.公有云平台

**国际**

AWS、谷歌云、Azure

**国内**

阿里云、华为云、腾讯云、七牛云

**参考文档**

- docker实力经典
- 官方文档

